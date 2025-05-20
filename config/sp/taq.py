from kxi import sp
import pykx as kx
import pandas as pd
import datetime

# Kafka setup
kfk_broker = 'kafka.trykdb.kx.com:443'
kfk_broker_options = {
    'sasl.username': 'demo',
    'sasl.password': 'demo',
    'sasl.mechanism': 'SCRAM-SHA-512',
    'security.protocol': 'SASL_SSL'
}

# Schema definitions
quote_schema_types = {
    'time': kx.TimestampAtom,
    'sym': kx.SymbolAtom,
    'bid': kx.FloatAtom,
    'ask': kx.FloatAtom,
    'bsize': kx.LongAtom,
    'asize': kx.LongAtom
}

trade_schema_types = {
    'time': kx.TimestampAtom,
    'sym': kx.SymbolAtom,
    'price': kx.FloatAtom,
    'size': kx.LongAtom
}

# Transform incoming JSON dicts to q table objects
def transform_dict_to_table(d):
    return kx.q.enlist(d)

# Aggregation: OHLCV
def ohlcv_agg(data):
    sql_query = """
        SELECT 
            date_trunc('second', time), 
            sym, 
            FIRST(price) AS OPEN, 
            MAX(price)   AS HIGH, 
            MIN(price)   AS LOW, 
            LAST(price)  AS CLOSE_X, 
            SUM(size)    AS VOL 
        FROM $1 
        GROUP BY sym, date_trunc('second', time)
        """
    return kx.q.sql(sql_query, data)

# Aggregation: VWAP
def vwap_agg(data):
    sql_query = """
        SELECT 
            date_trunc('second', time) as time,
            sym, 
            SUM(price * size) / SUM(size) AS vwap,
            SUM(size) AS accVol
        FROM $1 
        GROUP BY sym, date_trunc('second', time)
    """
    return kx.q.sql(sql_query, data)


# Trade stream
trade_source = (
    sp.read.from_kafka(topic='trade', brokers=kfk_broker, options=kfk_broker_options)
    | sp.decode.json()
    | sp.map(transform_dict_to_table, name='transform trade')
    | sp.transform.rename_columns({'timestamp': 'time'})
    | sp.transform.schema(trade_schema_types)
)

trade_pipeline = (
    trade_source
    | sp.window.timer(datetime.timedelta(milliseconds=1000))
    | sp.write.to_console()
    #| sp.write.to_stream('trade', 'data')
    #| sp.write.to_database('trade', 'kdbInsights', directWrite=False)
    #| sp.write.to_database(table='trade', database='kxi', directWrite=False, api_version=2, name='trade_writer')
)

ohlcv_pipeline = (
    trade_source
    | sp.window.tumbling(period=datetime.timedelta(seconds=60), time_column='time', sort=True)
    | sp.map(ohlcv_agg, name='ohlcv')
    | sp.transform.rename_columns({'OPEN': 'open', 'HIGH': 'high', 'LOW': 'low', 'CLOSE_X': 'close', 'VOL': 'volume'})  
    | sp.write.to_console()
    #| sp.write.to_stream('ohlcv', 'data')
    #| sp.write.to_database('ohlcv', 'kdbInsights', directWrite=False)
    #| sp.write.to_database(table='ohlcv', database='kxi', directWrite=False, api_version=2, name='ohlcv_writer')
)

vwap_pipeline = (
    trade_source
    | sp.window.tumbling(period=datetime.timedelta(seconds=60), time_column='time', sort=True)
    | sp.map(vwap_agg, name='vwap')
    | sp.write.to_console()
    #| sp.write.to_stream('vwap', 'data')
    #| sp.write.to_database('vwap', 'kdbInsights', directWrite=False)
    #| sp.write.to_database(table='vwap', database='kxi', directWrite=False, api_version=2, name='vwap_writer')
)

# Quote stream
quote_pipeline = (
    sp.read.from_kafka(topic='quote', brokers=kfk_broker, options=kfk_broker_options)
    | sp.decode.json()
    | sp.map(transform_dict_to_table, name='transform quote')
    | sp.transform.rename_columns({'timestamp': 'time'})
    | sp.transform.schema(quote_schema_types)
    | sp.window.timer(datetime.timedelta(milliseconds=500))
    | sp.write.to_console()
    #| sp.write.to_stream('quote', 'data')
    #| sp.write.to_database('quote', 'kdbInsights', directWrite=False)
    #| sp.write.to_database(table='quote', database='kxi', directWrite=False, api_version=2, name='quote_writer')
)

# Start pipelines
sp.run(trade_pipeline, ohlcv_pipeline, vwap_pipeline, quote_pipeline)

#from threading import Timer

#def safe_trigger():
#    try:
#        sp.trigger_write(["trade_writer", "ohlcv_writer", "vwap_writer", "quote_writer"])
#    except Exception as e:
#        print(f"Trigger failed: {e}")



# Safely delay trigger_write
#Timer(10.0, safe_trigger).start()


# Run all pipelines
#sp.run(trade_pipeline, ohlcv_pipeline, vwap_pipeline, quote_pipeline)


#from threading import Timer
# Trigger writes after a safe delay
#Timer(15.0, lambda: sp.trigger_write(["trade", "ohlcv", "vwap", "quote"])).start()

# Trigger write for all pipelines writing to the DB
#sp.trigger_write(["trade_writer", "ohlcv_writer", "vwap_writer", "quote_writer"])