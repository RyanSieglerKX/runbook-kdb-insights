.example.daAPI:{[table;column;multiplier;startTS;endTS]
    args:`table`startTS`endTS`agg!(table;startTS;endTS;enlist[column]!enlist column);
    data:@[.kxi.selectTable; args; {x}];
    res:?[data;();0b;`original_col`multiplied_col!(column;(*;column;multiplier))];
    (multiplier;res)
    };
.da.registerAPI[`.example.daAPI;
    .sapi.metaDescription["Example API"],
    .sapi.metaParam[`name`type`isReq`description!(`table;-11h;1b;"Table to query")],
    .sapi.metaParam[`name`type`isReq`description!(`column;-11h;1b;"Column to multiply")],
    .sapi.metaParam[`name`type`isReq`description!(`multiplier;-7h;1b;"Multiplier")],
    .sapi.metaParam[`name`type`isReq`description!(`scope;-99h;0b;"Workaround")],
    .sapi.metaReturn[`type`description!(98h;"Result of the select.")],
    .sapi.metaMisc[enlist[`safe]!enlist 1b]
    ];







.custom.aj:{[tradesTable; quotesTable; sym]
    argsT:`table`startTS`endTS`filter!(`trade;.z.d-1;.z.d+1;enlist(=;`sym;enlist`AAPL));
    argsQ:`table`startTS`endTS`filter!(`quote;.z.d-1;.z.d+1;enlist(=;`sym;enlist`AAPL));
    trade:.kxi.selectTable argsT;
    quote:.kxi.selectTable argsQ;
    trade: `sym`time xasc trade;
    quote: `sym`time xasc quote;
    res: aj[`sym`time;trade;quote];
    (sym;res)
    }

.da.registerAPI[`.custom.aj;
    .kxi.metaDescription["As-of join between trades and quotes tables (no time constraints)"],
    .kxi.metaParam[`name`type`isReq`description!(`tradesTable;-11h;1b;"Name of trades table")],
    .kxi.metaParam[`name`type`isReq`description!(`quotesTable;-11h;1b;"Name of quotes table")],
    .kxi.metaParam[`name`type`isReq`description!(`sym;-11h;1b;"Ticker symbol")],
    .kxi.metaReturn[`type`description!(98h;"Table with as-of joined quotes")],
    .kxi.metaMisc[enlist[`safe]!enlist 1b]
    ]

