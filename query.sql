SELECT 
    breaks.*,
    CASE 
        WHEN COALESCE(TSR_FACT_LINKED_KEYS_UITI, '') LIKE '% %' 
            THEN 'UITI linked to more than one UITI' 
        WHEN TSR_FACT_LINKED_KEYS_UITI IS NULL 
            THEN 'NO UITI LINKED. Should not be submitted thru REGHUB' 
        ELSE 'ONE to ONE UITI - UITI linkage' 
    END AS UITI_LINKAGE_CATEG
FROM (
    SELECT 
        B.*, 
        TS_FACT.ts_pty1,
        TS_FACT.ts_pty2,
        TS_FACT.keys_uti AS TSR_FACT_LINKED_KEYS_UITI,
        TS_FACT.keys_src_sys AS ts_src_sys,
        TS_FACT.alpha_trade_classfctn_ind AS alpha_trade_classfctn_ind
    FROM 
        GFOLYREG_WORK.APP_REGHUB_ESMA_BREAKS_CITI_SUBMISSION B
    LEFT JOIN (
        SELECT 
            rpt_uti,
            TRIM(CONCAT_WS(' ', COLLECT_LIST(DISTINCT keys_uti))) AS keys_uti, 
            TRIM(CONCAT_WS(' ', COLLECT_LIST(DISTINCT keys_src_sys))) AS keys_src_sys, 
            TRIM(CONCAT_WS(' ', COLLECT_LIST(DISTINCT msghdr_trd_clsftn))) AS alpha_trade_classfctn_ind,
            ts_pty1,
            ts_pty2
        FROM (
            SELECT DISTINCT
                TRIM(
                    CASE 
                        WHEN INSTR(keys_uti, keys_uti_prefix) = 1 THEN keys_uti
                        WHEN INSTR(keys_uti, amc_firm_lgl_enty_id) = 1 THEN keys_uti
                        WHEN INSTR(keys_uti, amc_cpty_lgl_enty_id) = 1 THEN keys_uti
                        ELSE CONCAT(keys_uti_prefix, '|', keys_uti) 
                    END
                ) AS rpt_uti,
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
            FROM 
                GFOLYREG_MANAGED.ESMA_TS_FACT_DATA A
            WHERE 
                A.state_status IN ('ACK', 'REPORTED')
        ) a 
        GROUP BY rpt_uti, ts_pty1, ts_pty2
    ) TS_FACT
    ON TRIM(B.UITI) = TRIM(TS_FACT.rpt_uti)
    AND B.reporting_counterparty_id = TS_FACT.ts_pty1
    AND B.counterparty_2 = TS_FACT.ts_pty2
) breaks;
