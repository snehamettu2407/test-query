SELECT 
    rpt_uti,
    CONCAT_WS(' ', COLLECT_LIST(DISTINCT keys_uti)) AS keys_uti,
    CONCAT_WS(' ', COLLECT_LIST(DISTINCT keys_src_sys)) AS keys_src_sys,
    CONCAT_WS(' ', COLLECT_LIST(DISTINCT msghdr_trd_clsftn)) AS alpha_trade_classfctn_ind,
    ts_pty1,
    ts_pty2
FROM 
(
    SELECT DISTINCT 
        ltrim(IF(instr(keys_uti, keys_uti_prefix) = 1
            OR instr(keys_uti, amc_firm_lgl_enty_id) = 1
            OR instr(keys_uti, amc_cpty_lgl_enty_id) = 1, keys_uti, 
            keys_uti_prefix || keys_uti)) AS rpt_uti,
        a.keys_uti,
        keys_src_sys,
        msghdr_trd_clsftn,
        CASE 
            WHEN keys_flow LIKE '%Citix%' THEN src_trd_pty1_id 
            ELSE src_trd_pty2_id 
        END AS ts_pty1,
        CASE 
            WHEN keys_flow LIKE '%Citix%' THEN src_trd_pty2_id 
            ELSE src_trd_pty1_id 
        END AS ts_pty2
    FROM table_name
) grouped_data
GROUP BY rpt_uti, ts_pty1, ts_pty2;

