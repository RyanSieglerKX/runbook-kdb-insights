
// .example.daAPI is an example of a data access function.
.example.multiQuery:{[table;column;multiplier;startTS;endTS]
    args:`table`startTS`endTS`agg!(table;startTS;endTS;enlist[column]!enlist column);
    data:@[.kxi.selectTable; args; {x}];
    res:?[data;();0b;`original_col`multiplied_col!(column;(*;column;multiplier))];
    :.kxi.response.ok(multiplier;res)
    };

.example.multiAgg:{[tbls]
    razed:raze last each tbls;
    res:select original_col, multiplied_col, multiplied_col_avg: avgs multiplied_col from razed;
    .kxi.response.ok res
    };

.example.i.multiMetadata:.kxi.metaDescription["Example API"],
    .kxi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table to query")],
    .kxi.metaParam[`name`type`isReq`description!(`column;-11h;1b;"Column to multiply")],
    .kxi.metaParam[`name`type`isReq`description!(`multiplier;-7h;1b;"Multiplier")],
    .kxi.metaParam[`name`type`isReq`description!(`scope;-99h;0b;"Workaround")],
    .kxi.metaReturn[`type`description!(98h;"Result of the select.")],
    .kxi.metaMisc[enlist[`safe]!enlist 1b]

// gw(`.example.daAPI;(`table`column`multiplier`startTS`endTS)!(`trade;`price;rand 1 2 3;"p"$.z.d;.z.p);`;(0#`)!())
.kxi.registerUDA `name`query`aggregation`metadata!(`.example.daAPI; `.example.multiQuery; `.example.multiAgg; .example.i.multiMetadata);



// .custom.aj is an example of an ASOF join aggregation function.
.custom.ajQuery:{[tradesTable;quotesTable;sym]
    show("Running .custom.ajQuery function"; tradesTable; quotesTable; sym; .z.p);

    argsT:`table`startTS`endTS`filter!(tradesTable;.z.d-1;.z.d+1;enlist(=;`sym;enlist sym));
    argsQ:`table`startTS`endTS`filter!(quotesTable;.z.d-1;.z.d+1;enlist(=;`sym;enlist sym));
    trade:`sym`time xasc .kxi.selectTable argsT;
    quote:`sym`time xasc .kxi.selectTable argsQ;
    res:aj[`sym`time;trade;quote];
    :.kxi.response.ok res
    }

.custom.ajAgg:{[res]
    show "Running .custom.ajAgg function";
    .debug.res:res;
    .kxi.response.ok raze res 
    }

.custom.i.ajMetadata:.kxi.metaDescription["As-of join between trades and quotes tables (no time constraints)"],
    .kxi.metaParam[`name`type`isReq`description!(`tradesTable;-11h;1b;"Name of trades table")],
    .kxi.metaParam[`name`type`isReq`description!(`quotesTable;-11h;1b;"Name of quotes table")],
    .kxi.metaParam[`name`type`isReq`description!(`sym;-11h;1b;"Ticker symbol")],
    .kxi.metaReturn[`type`description!(98h;"Table with as-of joined quotes")],
    .kxi.metaMisc[enlist[`safe]!enlist 1b]

// gw(`.custom.aj;(`tradesTable;`quotesTable;`sym)!(`trade;`quote;rand `IBM`GOOG`AAPL);`;(0#`)!())
.kxi.registerUDA `name`query`aggregation`metadata!(`.custom.aj; `.custom.ajQuery; `.custom.ajAgg; .custom.i.ajMetadata);
