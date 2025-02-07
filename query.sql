SELECT 
    rpt_uti,
    -- First, select distinct keys and then apply CONCAT_WS
    (SELECT CONCAT_WS(', ', COLLECT_LIST(keys_uti)) 
     FROM (SELECT DISTINCT keys_uti FROM table_name) AS distinct_keys) AS keys_uti,
     
    (SELECT CONCAT_WS(', ', COLLECT_LIST(keys_src_sys)) 
     FROM (SELECT DISTINCT keys_src_sys FROM table_name) AS distinct_sys) AS keys_src_sys,

    (SELECT CONCAT_WS(', ', COLLECT_LIST(msghdr_trd_clsftn)) 
     FROM (SELECT DISTINCT msghdr_trd_clsftn FROM table_name) AS distinct_clsftn) AS alpha_trade_classfctn_ind,

    ts_pty1,
    ts_pty2

FROM table_name;
