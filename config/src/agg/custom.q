// Sample Agg custom file.



// .example.aggAPI:{[tbls]
//     razed:raze last each tbls;
//     res:select original_col, multiplied_col_avg: avgs multiplied_col from razed;
//     .sapi.ok res
//     };
// .sgagg.registerAggFn[`.example.aggAPI;
//     .sapi.metaDescription["Average aggregator"],
//     .sapi.metaParam[`name`type`description!(`tbls;0h;"Tables received from DAPs")],
//     .sapi.metaReturn`type`description!(98h;"Running average of multiplied column");
//     `.example.daAPI
//     ];




// Sample Agg custom file.

// Can load other files within this file. Note that the current directory
// is the directory of this file (in this example: /opt/kx/custom).
/ \l subFolder/otherFile1.q
/ \l subFolder/otherFile2.q



//
// @desc    Agg function that does an average daily count by sym.
//
// @param   res  {table[]}   List of tables from DAPs
//
// @return      {table}     
//
simpleAgg:{[res]
    // res:select sum cnt by sym,date from raze 0!'tbls; / Join common dates
    show "Running simpleAgg function";
    .debug.res:res;
    .sapi.ok raze res 
    }


//
// Note also that an aggregation function can be default aggregation function for multiple APIs. E.g.
//  .sgagg.registerAggFn[`myAggFn;();`api1`api2`api3]
//

.sgagg.registerAggFn[`simpleAgg;
    .kxi.metaDescription["ASOF join aggregation"],
    .kxi.metaParam[`name`type`description!(`res;0h;"Tables received from DAPs")],
    .kxi.metaReturn`type`description!(98h;"ASOF join");
    `.custom.aj];   // Register as default aggregation function for this API