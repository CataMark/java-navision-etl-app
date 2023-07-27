do $$
declare
    _dbname text := current_database();
begin
    if _dbname != 'any' then
        raise exception 'not in "any" database';
    end if;
end;
$$ language plpgsql;

/* 0001.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_check_data_integrity"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_check_data_integrity()
as $$
declare
    _count int;
begin
    raise info 'incepere verificare';

    /* verificare production orders */
    _count := (select count(*) from
                (select "No_", count(*) as poz from nav.tbl_int_production_order group by "No_") as a
            where a.poz > 1);
    if _count is not null and _count > 0 then
        raise warning 'tabela "nav.tbl_int_production_order" contine % comenzi duplicate', _count;
    end if;

    /* verificare production order lines */
    _count := 0;
    _count := (select count(*) from
                (select "Prod_ Order No_", "Line No_", count(*) as poz from nav.tbl_int_prod_order_line group by "Prod_ Order No_", "Line No_") as a
            where a.poz > 1);
    if _count is not null and _count > 0 then
        raise warning 'tabela "nav.tbl_int_prod_order_line" contine % pozitii duplicate', _count;
    end if;

    /* verificare production order components */
    _count := 0;
    _count := (select count(*) from
                (select "Prod_ Order No_", "Prod_ Order Line No_", "Line No_", count(*) as poz from nav.tbl_int_prod_order_component group by "Prod_ Order No_", "Prod_ Order Line No_", "Line No_") as a
            where a.poz > 1);
    if _count is not null and _count > 0 then
        raise warning 'tabela "nav.tbl_int_prod_order_component" pozitii % duplicate', _count;
    end if;

    /* verificare production order routing lines */
    _count := 0;
    _count := (select count(*) from
                (select "Prod_ Order No_", "Routing Reference No_", "Routing No_", "Operation No_", count(*) as poz from nav.tbl_int_prod_order_routing_line
                group by "Prod_ Order No_", "Routing Reference No_", "Routing No_", "Operation No_") as a
            where a.poz > 1);
    if _count is not null and _count > 0 then
        raise warning 'tabela "nav.tbl_int_prod_order_routing_line" pozitii % duplicate', _count;
    end if;

    raise info 'verificare finalizata%', E'\n';
end;
$$ language plpgsql;


/* 0001.02 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating function "fnc_last_rowvers_get"';
end;
$$ language plpgsql;

create or replace function nav.fnc_last_rowvers_get (tgt_tbl text)
returns table (rowvers bigint)
as $$
declare
    _rowvers bigint;
begin
    _rowvers := (select a.rowvers from nav.tbl_int_last_rowvers as a where a.target_tbl = tgt_tbl limit 1);

    return query
        select coalesce(_rowvers, 0) as rowvers;
end;
$$ language plpgsql;

/* 0002.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_prod_bom_header_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_prod_bom_header_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_prod_bom_header'), 0);

    delete from nav.tbl_int_prod_bom_header as a
    where a."timestamp" > _rvers;

    insert into nav.tbl_int_prod_bom_header as t ("timestamp", "No_", "Description", "Description 2", "Search Name", "Unit of Measure Code", "Low-Level Code", "Creation Date", "Last Date Modified", "Status", "Version Nos_", "No_ Series", "Type", mod_de)
    select "timestamp", "No_", "Description", "Description 2", "Search Name", "Unit of Measure Code", "Low-Level Code", "Creation Date", "Last Date Modified", "Status", "Version Nos_", "No_ Series", "Type", mod_de
    from nav.tbl_int_prod_bom_header_load
    on conflict on constraint tbl_int_prod_bom_header_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Description" = excluded."Description",
        "Description 2" = excluded."Description 2",
        "Search Name" = excluded."Search Name",
        "Unit of Measure Code" = excluded."Unit of Measure Code",
        "Low-Level Code" = excluded."Low-Level Code",
        "Creation Date" = excluded."Creation Date",
        "Last Date Modified" = excluded."Last Date Modified",
        "Status" = excluded."Status",
        "Version Nos_" = excluded."Version Nos_",
        "No_ Series" = excluded."No_ Series",
        "Type" = excluded."Type",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_prod_bom_header_load;
end;
$$ language plpgsql;

/* 0002.02 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_prod_bom_line_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_prod_bom_line_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_prod_bom_header'), 0);

    delete from nav.tbl_int_prod_bom_line as a
    using nav.tbl_int_prod_bom_header as b
    where a."Production BOM No_" = b."No_" and b."timestamp" > _rvers;

    insert into nav.tbl_int_prod_bom_line as t ("timestamp", "Production BOM No_", "Version Code", "Line No_", "Type", "No_", "Description", "Unit of Measure Code", "Quantity", "Position",
                                                "Position 2", "Position 3", "Lead-Time Offset", "Routing Link Code", "Scrap _", "Variant Code", "Starting Date", "Ending Date", "Length", "Width",
                                                "Weight", "Depth", "Calculation Formula", "Quantity per", "Fitting Note", "Parcel Code", "Randament _", "Rebut _", mod_de)
    select "timestamp", "Production BOM No_", "Version Code", "Line No_", "Type", "No_", "Description", "Unit of Measure Code", "Quantity", "Position",
            "Position 2", "Position 3", "Lead-Time Offset", "Routing Link Code", "Scrap _", "Variant Code", "Starting Date", "Ending Date", "Length", "Width",
            "Weight", "Depth", "Calculation Formula", "Quantity per", "Fitting Note", "Parcel Code", "Randament _", "Rebut _", mod_de
    from nav.tbl_int_prod_bom_line_load
    on conflict on constraint tbl_int_prod_bom_line_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Type" = excluded."Type",
        "No_" = excluded."No_",
        "Description" = excluded."Description",
        "Unit of Measure Code" = excluded."Unit of Measure Code",
        "Quantity" = excluded."Quantity",
        "Position" = excluded."Position",
        "Position 2" = excluded."Position 2",
        "Position 3" = excluded."Position 3",
        "Lead-Time Offset" = excluded."Lead-Time Offset",
        "Routing Link Code" = excluded."Routing Link Code",
        "Scrap _" = excluded."Scrap _",
        "Variant Code" = excluded."Variant Code",
        "Starting Date" = excluded."Starting Date",
        "Ending Date" = excluded."Ending Date",
        "Length" = excluded."Length",
        "Width" = excluded."Width",
        "Weight" = excluded."Weight",
        "Depth" = excluded."Depth",
        "Calculation Formula" = excluded."Calculation Formula",
        "Quantity per" = excluded."Quantity per",
        "Fitting Note" = excluded."Fitting Note",
        "Parcel Code" = excluded."Parcel Code",
        "Randament _" = excluded."Randament _",
        "Rebut _" = excluded."Rebut _",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_prod_bom_line_load;
end;
$$ language plpgsql;

/* 0002.03 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_prod_bom_vers_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_prod_bom_vers_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_prod_bom_header'), 0);

    delete from nav.tbl_int_prod_bom_vers as a
    using nav.tbl_int_prod_bom_header as b
    where a."Production BOM No_" = b."No_" and b."timestamp" > _rvers;

    insert into nav.tbl_int_prod_bom_vers as t ("timestamp", "Production BOM No_", "Version Code", "Description", "Starting Date", "Unit of Measure Code", "Last Date Modified",
                                                "Status", "No_ Series", "Location Code", mod_de)
    select "timestamp", "Production BOM No_", "Version Code", "Description", "Starting Date", "Unit of Measure Code", "Last Date Modified", "Status", "No_ Series", "Location Code", mod_de
    from nav.tbl_int_prod_bom_vers_load
    on conflict on constraint tbl_int_prod_bom_vers_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Description" = excluded."Description",
        "Starting Date" = excluded."Starting Date",
        "Unit of Measure Code" = excluded."Unit of Measure Code",
        "Last Date Modified" = excluded."Last Date Modified",
        "Status" = excluded."Status",
        "No_ Series" = excluded."No_ Series",
        "Location Code" = excluded."Location Code",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_prod_bom_vers_load;
end;
$$ language plpgsql;

/* 0002.04 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_prod_bom_all_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_prod_bom_all_merge_load()
as $$
declare
    _rvers bigint;
begin
    call nav.prc_prod_bom_line_merge_load();
    call nav.prc_prod_bom_vers_merge_load();
    call nav.prc_prod_bom_header_merge_load(); /* trebuie sa fie ultima */

    _rvers := coalesce((select min("timestamp") from nav.tbl_int_prod_bom_header where "Status" != 3), 0) - 1; /* status 3 = Closed */

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_prod_bom_header', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0003.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_routing_header_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_routing_header_merge_load()
as $$
declare
     _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_routing_header'), 0);

    delete from nav.tbl_int_routing_header as a
    where a."timestamp" > _rvers;

    insert into nav.tbl_int_routing_header as t ("timestamp", "No_", "Description", "Description 2", "Search Description", "Last Date Modified", "Status", "Type", "Version Nos_", "No_ Series", mod_de)
    select "timestamp", "No_", "Description", "Description 2", "Search Description", "Last Date Modified", "Status", "Type", "Version Nos_", "No_ Series", mod_de
    from nav.tbl_int_routing_header_load
    on conflict on constraint tbl_int_routing_header_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Description" = excluded."Description",
        "Description 2" = excluded."Description 2",
        "Search Description" = excluded."Search Description",
        "Last Date Modified" = excluded."Last Date Modified",
        "Status" = excluded."Status",
        "Type" = excluded."Type",
        "Version Nos_" = excluded."Version Nos_",
        "No_ Series" = excluded."No_ Series",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_routing_header_load;
end;
$$ language plpgsql;

/* 0003.02 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_routing_line_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_routing_line_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_routing_header'), 0);

    delete from nav.tbl_int_routing_line as a
    using nav.tbl_int_routing_header as b
    where a."Routing No_" = b."No_" and b."timestamp" > _rvers;

    insert into nav.tbl_int_routing_line as t ("timestamp", "Routing No_", "Version Code", "Operation No_", "Next Operation No_", "Previous Operation No_", "Type", "No_",
                                            "Work Center No_", "Work Center Group Code", "Description", "Setup Time", "Run Time", "Wait Time", "Move Time", "Fixed Scrap Quantity",
                                            "Lot Size", "Scrap Factor _", "Setup Time Unit of Meas_ Code", "Run Time Unit of Meas_ Code", "Wait Time Unit of Meas_ Code", "Move Time Unit of Meas_ Code",
                                            "Minimum Process Time", "Maximum Process Time", "Concurrent Capacities", "Send-Ahead Quantity", "Routing Link Code", "Standard Task Code",
                                            "Unit Cost per", "Recalculate", "Sequence No_ (Forward)", "Sequence No_ (Backward)", "Fixed Scrap Qty_ (Accum_)", "Scrap Factor _ (Accumulated)",
                                            "Machine Efficiency (_)", "No_ Of Workers", "Net Setup Time", "Net Run Time", "Description 2", mod_de)
    select "timestamp", "Routing No_", "Version Code", "Operation No_", "Next Operation No_", "Previous Operation No_", "Type", "No_",
            "Work Center No_", "Work Center Group Code", "Description", "Setup Time", "Run Time", "Wait Time", "Move Time", "Fixed Scrap Quantity",
            "Lot Size", "Scrap Factor _", "Setup Time Unit of Meas_ Code", "Run Time Unit of Meas_ Code", "Wait Time Unit of Meas_ Code", "Move Time Unit of Meas_ Code",
            "Minimum Process Time", "Maximum Process Time", "Concurrent Capacities", "Send-Ahead Quantity", "Routing Link Code", "Standard Task Code",
            "Unit Cost per", "Recalculate", "Sequence No_ (Forward)", "Sequence No_ (Backward)", "Fixed Scrap Qty_ (Accum_)", "Scrap Factor _ (Accumulated)",
            "Machine Efficiency (_)", "No_ Of Workers", "Net Setup Time", "Net Run Time", "Description 2", mod_de
    from nav.tbl_int_routing_line_load
    on conflict on constraint tbl_int_routing_line_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Next Operation No_" = excluded."Next Operation No_",
        "Previous Operation No_" = excluded."Previous Operation No_",
        "Type" = excluded."Type",
        "No_" = excluded."No_",
        "Work Center No_" = excluded."Work Center No_",
        "Work Center Group Code" = excluded."Work Center Group Code",
        "Description" = excluded."Description",
        "Setup Time" = excluded."Setup Time",
        "Run Time" = excluded."Run Time",
        "Wait Time" = excluded."Wait Time",
        "Move Time" = excluded."Move Time",
        "Fixed Scrap Quantity" = excluded."Fixed Scrap Quantity",
        "Lot Size" = excluded."Lot Size",
        "Scrap Factor _" = excluded."Scrap Factor _",
        "Setup Time Unit of Meas_ Code" = excluded."Setup Time Unit of Meas_ Code",
        "Run Time Unit of Meas_ Code" = excluded."Run Time Unit of Meas_ Code",
        "Wait Time Unit of Meas_ Code" = excluded."Wait Time Unit of Meas_ Code",
        "Move Time Unit of Meas_ Code" = excluded."Move Time Unit of Meas_ Code",
        "Minimum Process Time" = excluded."Minimum Process Time",
        "Maximum Process Time" = excluded."Maximum Process Time",
        "Concurrent Capacities" = excluded."Concurrent Capacities",
        "Send-Ahead Quantity" = excluded."Send-Ahead Quantity",
        "Routing Link Code" = excluded."Routing Link Code",
        "Standard Task Code" = excluded."Standard Task Code",
        "Unit Cost per" = excluded."Unit Cost per",
        "Recalculate" = excluded."Recalculate",
        "Sequence No_ (Forward)" = excluded."Sequence No_ (Forward)",
        "Sequence No_ (Backward)" = excluded."Sequence No_ (Backward)",
        "Fixed Scrap Qty_ (Accum_)" = excluded."Fixed Scrap Qty_ (Accum_)",
        "Scrap Factor _ (Accumulated)" = excluded."Scrap Factor _ (Accumulated)",
        "Machine Efficiency (_)" = excluded."Machine Efficiency (_)",
        "No_ Of Workers" = excluded."No_ Of Workers",
        "Net Setup Time" = excluded."Net Setup Time",
        "Net Run Time" = excluded."Net Run Time",
        "Description 2" = excluded."Description 2",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_routing_line_load;
end;
$$ language plpgsql;

/* 0003.03 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_routing_vers_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_routing_vers_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_routing_header'), 0);

    delete from nav.tbl_int_routing_vers as a
    using nav.tbl_int_routing_header as b
    where a."Routing No_" = b."No_" and b."timestamp" > _rvers;

    insert into nav.tbl_int_routing_vers as t ("timestamp", "Routing No_", "Version Code", "Description", "Starting Date", "Status", "Type", "Last Date Modified", "No_ Series", "Location Code", mod_de)
    select "timestamp", "Routing No_", "Version Code", "Description", "Starting Date", "Status", "Type", "Last Date Modified", "No_ Series", "Location Code", mod_de
    from nav.tbl_int_routing_vers_load
    on conflict on constraint tbl_int_routing_vers_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Description" = excluded."Description",
        "Starting Date" = excluded."Starting Date",
        "Status" = excluded."Status",
        "Type" = excluded."Type",
        "Last Date Modified" = excluded."Last Date Modified",
        "No_ Series" = excluded."No_ Series",
        "Location Code" = excluded."Location Code",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_routing_vers_load;
end;
$$ language plpgsql;


/* 0003.04 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_routing_all_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_routing_all_merge_load()
as $$
declare
    _rvers bigint;
begin
    call nav.prc_routing_line_merge_load();
    call nav.prc_routing_vers_merge_load();
    call nav.prc_routing_header_merge_load(); /* trebuie sa fie ultima */

    _rvers := coalesce((select min("timestamp") from nav.tbl_int_routing_header where "Status" != 3), 0) - 1; /* status 3 = Closed */

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_routing_header', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0004.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_item_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_item_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_item as t ("timestamp", "No_", "No_ 2", "Description", "Search Description", "Description 2", "Base Unit of Measure", "Price Unit Conversion", "Type",
                                    "Inventory Posting Group", "Shelf No_", "Item Disc_ Group", "Allow Invoice Disc_", "Statistics Group", "Commission Group", "Unit Price",
                                    "Price_Profit Calculation", "Profit _", "Costing Method", "Unit Cost", "Standard Cost", "Last Direct Cost", "Indirect Cost _", "Cost is Adjusted",
                                    "Allow Online Adjustment", "Vendor No_", "Vendor Item No_", "Lead Time Calculation", "Reorder Point", "Maximum Inventory", "Reorder Quantity",
                                    "Alternative Item No_", "Unit List Price", "Duty Due _", "Duty Code", "Gross Weight", "Net Weight", "Units per Parcel", "Unit Volume", "Durability",
                                    "Freight Type", "Tariff No_", "Duty Unit Conversion", "Country_Region Purchased Code", "Budget Quantity", "Budgeted Amount", "Budget Profit", "Blocked",
                                    "Last Date Modified", "Last Time Modified", "Price Includes VAT", "VAT Bus_ Posting Gr_ (Price)", "Gen_ Prod_ Posting Group", "Picture",
                                    "Country_Region of Origin Code", "Automatic Ext_ Texts", "No_ Series", "Tax Group Code", "VAT Prod_ Posting Group", "Reserve", "Global Dimension 1 Code",
                                    "Global Dimension 2 Code", "Stockout Warning", "Prevent Negative Inventory", "Application Wksh_ User ID", "Assembly Policy", "GTIN", "Default Deferral Template Code",
                                    "Low-Level Code", "Lot Size", "Serial Nos_", "Last Unit Cost Calc_ Date", "Rolled-up Material Cost", "Rolled-up Capacity Cost", "Scrap _", "Inventory Value Zero",
                                    "Discrete Order Quantity", "Minimum Order Quantity", "Maximum Order Quantity", "Safety Stock Quantity", "Order Multiple", "Safety Lead Time", "Flushing Method",
                                    "Replenishment System", "Rounding Precision", "Sales Unit of Measure", "Purch_ Unit of Measure", "Time Bucket", "Reordering Policy", "Include Inventory",
                                    "Manufacturing Policy", "Rescheduling Period", "Lot Accumulation Period", "Dampener Period", "Dampener Quantity", "Overflow Level", "Manufacturer Code",
                                    "Item Category Code", "Created From Nonstock Item", "Product Group Code", "Service Item Group", "Item Tracking Code", "Lot Nos_", "Expiration Calculation",
                                    "Warehouse Class Code", "Special Equipment Code", "Put-away Template Code", "Put-away Unit of Measure Code", "Phys Invt Counting Period Code", "Last Counting Period Update",
                                    "Use Cross-Docking", "Next Counting Start Date", "Next Counting End Date", "Kit BOM No_", "SAV BOM No_", "KitPurchPriceToBeRecalculated", "Plan No_", "Product dimensions mounted",
                                    "ABC", "Date (ABC)", "Alerte", "Cod ABCD", "Manufacture", "Range", "Category 1", "Category 2", "Technical Family", "Montat", "Is a Prototype", "Code Prototype", "MrpDate",
                                    "Status", "Life cycle stages", "Packages no_", "Old No_", "Oty_ per pallet", "Custom Tax _", "Custom Commission _", "Full Description", "Routing No_", "Production BOM No_",
                                    "Single-Level Material Cost", "Single-Level Capacity Cost", "Single-Level Subcontrd_ Cost", "Single-Level Cap_ Ovhd Cost", "Single-Level Mfg_ Ovhd Cost", "Overhead Rate",
                                    "Rolled-up Subcontracted Cost", "Rolled-up Mfg_ Ovhd Cost", "Rolled-up Cap_ Overhead Cost", "Order Tracking Policy", "Critical", "Common Item No_", "FSC", "Tip PF",
                                    "Consumption Scrap _", "Production at Location", "SAV Manufacture", mod_de)
    select "timestamp", "No_", "No_ 2", "Description", "Search Description", "Description 2", "Base Unit of Measure", "Price Unit Conversion", "Type",
            "Inventory Posting Group", "Shelf No_", "Item Disc_ Group", "Allow Invoice Disc_", "Statistics Group", "Commission Group", "Unit Price",
            "Price_Profit Calculation", "Profit _", "Costing Method", "Unit Cost", "Standard Cost", "Last Direct Cost", "Indirect Cost _", "Cost is Adjusted",
            "Allow Online Adjustment", "Vendor No_", "Vendor Item No_", "Lead Time Calculation", "Reorder Point", "Maximum Inventory", "Reorder Quantity",
            "Alternative Item No_", "Unit List Price", "Duty Due _", "Duty Code", "Gross Weight", "Net Weight", "Units per Parcel", "Unit Volume", "Durability",
            "Freight Type", "Tariff No_", "Duty Unit Conversion", "Country_Region Purchased Code", "Budget Quantity", "Budgeted Amount", "Budget Profit", "Blocked",
            "Last Date Modified", "Last Time Modified", "Price Includes VAT", "VAT Bus_ Posting Gr_ (Price)", "Gen_ Prod_ Posting Group", "Picture",
            "Country_Region of Origin Code", "Automatic Ext_ Texts", "No_ Series", "Tax Group Code", "VAT Prod_ Posting Group", "Reserve", "Global Dimension 1 Code",
            "Global Dimension 2 Code", "Stockout Warning", "Prevent Negative Inventory", "Application Wksh_ User ID", "Assembly Policy", "GTIN", "Default Deferral Template Code",
            "Low-Level Code", "Lot Size", "Serial Nos_", "Last Unit Cost Calc_ Date", "Rolled-up Material Cost", "Rolled-up Capacity Cost", "Scrap _", "Inventory Value Zero",
            "Discrete Order Quantity", "Minimum Order Quantity", "Maximum Order Quantity", "Safety Stock Quantity", "Order Multiple", "Safety Lead Time", "Flushing Method",
            "Replenishment System", "Rounding Precision", "Sales Unit of Measure", "Purch_ Unit of Measure", "Time Bucket", "Reordering Policy", "Include Inventory",
            "Manufacturing Policy", "Rescheduling Period", "Lot Accumulation Period", "Dampener Period", "Dampener Quantity", "Overflow Level", "Manufacturer Code",
            "Item Category Code", "Created From Nonstock Item", "Product Group Code", "Service Item Group", "Item Tracking Code", "Lot Nos_", "Expiration Calculation",
            "Warehouse Class Code", "Special Equipment Code", "Put-away Template Code", "Put-away Unit of Measure Code", "Phys Invt Counting Period Code", "Last Counting Period Update",
            "Use Cross-Docking", "Next Counting Start Date", "Next Counting End Date", "Kit BOM No_", "SAV BOM No_", "KitPurchPriceToBeRecalculated", "Plan No_", "Product dimensions mounted",
            "ABC", "Date (ABC)", "Alerte", "Cod ABCD", "Manufacture", "Range", "Category 1", "Category 2", "Technical Family", "Montat", "Is a Prototype", "Code Prototype", "MrpDate",
            "Status", "Life cycle stages", "Packages no_", "Old No_", "Oty_ per pallet", "Custom Tax _", "Custom Commission _", "Full Description", "Routing No_", "Production BOM No_",
            "Single-Level Material Cost", "Single-Level Capacity Cost", "Single-Level Subcontrd_ Cost", "Single-Level Cap_ Ovhd Cost", "Single-Level Mfg_ Ovhd Cost", "Overhead Rate",
            "Rolled-up Subcontracted Cost", "Rolled-up Mfg_ Ovhd Cost", "Rolled-up Cap_ Overhead Cost", "Order Tracking Policy", "Critical", "Common Item No_", "FSC", "Tip PF",
            "Consumption Scrap _", "Production at Location", "SAV Manufacture", mod_de
    from nav.tbl_int_item_load
    on conflict on constraint tbl_int_item_pk
    do update set
        "timestamp" = excluded."timestamp",
        "No_ 2" = excluded."No_ 2",
        "Description" = excluded."Description",
        "Search Description" = excluded."Search Description",
        "Description 2" = excluded."Description 2",
        "Base Unit of Measure" = excluded."Base Unit of Measure",
        "Price Unit Conversion" = excluded."Price Unit Conversion",
        "Type" = excluded."Type",
        "Inventory Posting Group" = excluded."Inventory Posting Group",
        "Shelf No_" = excluded."Shelf No_",
        "Item Disc_ Group" = excluded."Item Disc_ Group",
        "Allow Invoice Disc_" = excluded."Allow Invoice Disc_",
        "Statistics Group" = excluded."Statistics Group",
        "Commission Group" = excluded."Commission Group",
        "Unit Price" = excluded."Unit Price",
        "Price_Profit Calculation" = excluded."Price_Profit Calculation",
        "Profit _" = excluded."Profit _",
        "Costing Method" = excluded."Costing Method",
        "Unit Cost" = excluded."Unit Cost",
        "Standard Cost" = excluded."Standard Cost",
        "Last Direct Cost" = excluded."Last Direct Cost",
        "Indirect Cost _" = excluded."Indirect Cost _",
        "Cost is Adjusted" = excluded."Cost is Adjusted",
        "Allow Online Adjustment" = excluded."Allow Online Adjustment",
        "Vendor No_" = excluded."Vendor No_",
        "Vendor Item No_" = excluded."Vendor Item No_",
        "Lead Time Calculation" = excluded."Lead Time Calculation",
        "Reorder Point" = excluded."Reorder Point",
        "Maximum Inventory" = excluded."Maximum Inventory",
        "Reorder Quantity" = excluded."Reorder Quantity",
        "Alternative Item No_" = excluded."Alternative Item No_",
        "Unit List Price" = excluded."Unit List Price",
        "Duty Due _" = excluded."Duty Due _",
        "Duty Code" = excluded."Duty Code",
        "Gross Weight" = excluded."Gross Weight",
        "Net Weight" = excluded."Net Weight",
        "Units per Parcel" = excluded."Units per Parcel",
        "Unit Volume" = excluded."Unit Volume",
        "Durability" = excluded."Durability",
        "Freight Type" = excluded."Freight Type",
        "Tariff No_" = excluded."Tariff No_",
        "Duty Unit Conversion" = excluded."Duty Unit Conversion",
        "Country_Region Purchased Code" = excluded."Country_Region Purchased Code",
        "Budget Quantity" = excluded."Budget Quantity",
        "Budgeted Amount" = excluded."Budgeted Amount",
        "Budget Profit" = excluded."Budget Profit",
        "Blocked" = excluded."Blocked",
        "Last Date Modified" = excluded."Last Date Modified",
        "Last Time Modified" = excluded."Last Time Modified",
        "Price Includes VAT" = excluded."Price Includes VAT",
        "VAT Bus_ Posting Gr_ (Price)" = excluded."VAT Bus_ Posting Gr_ (Price)",
        "Gen_ Prod_ Posting Group" = excluded."Gen_ Prod_ Posting Group",
        "Picture" = excluded."Picture",
        "Country_Region of Origin Code" = excluded."Country_Region of Origin Code",
        "Automatic Ext_ Texts" = excluded."Automatic Ext_ Texts",
        "No_ Series" = excluded."No_ Series",
        "Tax Group Code" = excluded."Tax Group Code",
        "VAT Prod_ Posting Group" = excluded."VAT Prod_ Posting Group",
        "Reserve" = excluded."Reserve",
        "Global Dimension 1 Code" = excluded."Global Dimension 1 Code",
        "Global Dimension 2 Code" = excluded."Global Dimension 2 Code",
        "Stockout Warning" = excluded."Stockout Warning",
        "Prevent Negative Inventory" = excluded."Prevent Negative Inventory",
        "Application Wksh_ User ID" = excluded."Application Wksh_ User ID",
        "Assembly Policy" = excluded."Assembly Policy",
        "GTIN" = excluded."GTIN",
        "Default Deferral Template Code" = excluded."Default Deferral Template Code",
        "Low-Level Code" = excluded."Low-Level Code",
        "Lot Size" = excluded."Lot Size",
        "Serial Nos_" = excluded."Serial Nos_",
        "Last Unit Cost Calc_ Date" = excluded."Last Unit Cost Calc_ Date",
        "Rolled-up Material Cost" = excluded."Rolled-up Material Cost",
        "Rolled-up Capacity Cost" = excluded."Rolled-up Capacity Cost",
        "Scrap _" = excluded."Scrap _",
        "Inventory Value Zero" = excluded."Inventory Value Zero",
        "Discrete Order Quantity" = excluded."Discrete Order Quantity",
        "Minimum Order Quantity" = excluded."Minimum Order Quantity",
        "Maximum Order Quantity" = excluded."Maximum Order Quantity",
        "Safety Stock Quantity" = excluded."Safety Stock Quantity",
        "Order Multiple" = excluded."Order Multiple" ,
        "Safety Lead Time" = excluded."Safety Lead Time",
        "Flushing Method" = excluded."Flushing Method",
        "Replenishment System" = excluded."Replenishment System",
        "Rounding Precision" = excluded."Rounding Precision",
        "Sales Unit of Measure" = excluded."Sales Unit of Measure",
        "Purch_ Unit of Measure" = excluded."Purch_ Unit of Measure",
        "Time Bucket" = excluded."Time Bucket",
        "Reordering Policy" = excluded."Reordering Policy",
        "Include Inventory" = excluded."Include Inventory",
        "Manufacturing Policy" = excluded."Manufacturing Policy",
        "Rescheduling Period" = excluded."Rescheduling Period",
        "Lot Accumulation Period" = excluded."Lot Accumulation Period",
        "Dampener Period" = excluded."Dampener Period",
        "Dampener Quantity" = excluded."Dampener Quantity",
        "Overflow Level" = excluded."Overflow Level",
        "Manufacturer Code" = excluded."Manufacturer Code",
        "Item Category Code" = excluded."Item Category Code",
        "Created From Nonstock Item" = excluded."Created From Nonstock Item" ,
        "Product Group Code" = excluded."Product Group Code",
        "Service Item Group" = excluded."Service Item Group",
        "Item Tracking Code" = excluded."Item Tracking Code",
        "Lot Nos_" = excluded."Lot Nos_",
        "Expiration Calculation" = excluded."Expiration Calculation",
        "Warehouse Class Code" = excluded."Warehouse Class Code",
        "Special Equipment Code" = excluded."Special Equipment Code",
        "Put-away Template Code" = excluded."Put-away Template Code",
        "Put-away Unit of Measure Code" = excluded."Put-away Unit of Measure Code",
        "Phys Invt Counting Period Code" = excluded."Phys Invt Counting Period Code",
        "Last Counting Period Update" = excluded."Last Counting Period Update",
        "Use Cross-Docking" = excluded."Use Cross-Docking",
        "Next Counting Start Date" = excluded."Next Counting Start Date",
        "Next Counting End Date" = excluded."Next Counting End Date",
        "Kit BOM No_" = excluded."Kit BOM No_",
        "SAV BOM No_" = excluded."SAV BOM No_",
        "KitPurchPriceToBeRecalculated" = excluded."KitPurchPriceToBeRecalculated",
        "Plan No_" = excluded."Plan No_",
        "Product dimensions mounted" = excluded."Product dimensions mounted",
        "ABC" = excluded."ABC",
        "Date (ABC)" = excluded."Date (ABC)",
        "Alerte" = excluded."Alerte",
        "Cod ABCD" = excluded."Cod ABCD",
        "Manufacture" = excluded."Manufacture",
        "Range" = excluded."Range",
        "Category 1" = excluded."Category 1",
        "Category 2" = excluded."Category 2",
        "Technical Family" = excluded."Technical Family",
        "Montat" = excluded."Montat",
        "Is a Prototype" = excluded."Is a Prototype",
        "Code Prototype" = excluded."Code Prototype",
        "MrpDate" = excluded."MrpDate",
        "Status" = excluded."Status",
        "Life cycle stages" = excluded."Life cycle stages",
        "Packages no_" = excluded."Packages no_",
        "Old No_" = excluded."Old No_",
        "Oty_ per pallet" = excluded."Oty_ per pallet",
        "Custom Tax _" = excluded."Custom Tax _",
        "Custom Commission _" = excluded."Custom Commission _",
        "Full Description" = excluded."Full Description",
        "Routing No_" = excluded."Routing No_",
        "Production BOM No_" = excluded."Production BOM No_",
        "Single-Level Material Cost" = excluded."Single-Level Material Cost",
        "Single-Level Capacity Cost" = excluded."Single-Level Capacity Cost",
        "Single-Level Subcontrd_ Cost" = excluded."Single-Level Subcontrd_ Cost",
        "Single-Level Cap_ Ovhd Cost" = excluded."Single-Level Cap_ Ovhd Cost",
        "Single-Level Mfg_ Ovhd Cost" = excluded."Single-Level Mfg_ Ovhd Cost",
        "Overhead Rate" = excluded."Overhead Rate",
        "Rolled-up Subcontracted Cost" = excluded."Rolled-up Subcontracted Cost",
        "Rolled-up Mfg_ Ovhd Cost" = excluded."Rolled-up Mfg_ Ovhd Cost",
        "Rolled-up Cap_ Overhead Cost" = excluded."Rolled-up Cap_ Overhead Cost",
        "Order Tracking Policy" = excluded."Order Tracking Policy",
        "Critical" = excluded."Critical",
        "Common Item No_" = excluded."Common Item No_",
        "FSC" = excluded."FSC",
        "Tip PF" = excluded."Tip PF",
        "Consumption Scrap _" = excluded."Consumption Scrap _",
        "Production at Location" = excluded."Production at Location",
        "SAV Manufacture" = excluded."SAV Manufacture",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_item_load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_item as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_item', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;


/* 0004.04 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_technical_family__load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_technical_family__load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_technical_family_ as t ("timestamp", "Code", "Description", "Description 2", mod_de)
    select "timestamp", "Code", "Description", "Description 2", mod_de
    from nav.tbl_int_technical_family__load
    on conflict on constraint tbl_int_technical_family__pk do
    update set
        "timestamp" = excluded."timestamp",
        "Description" = excluded."Description",
        "Description 2" = excluded."Description 2",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_technical_family__load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_technical_family_ as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_technical_family_', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0005.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_bom_component_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_bom_component_merge_load()
as $$
begin
    delete from nav.tbl_int_bom_component;

    insert into nav.tbl_int_bom_component as t("timestamp", "Parent Item No_", "Line No_", "Type", "No_", "Description", "Unit of Measure Code", "Quantity per", "Position", "Position 2",
                                            "Position 3", "Machine No_", "Lead-Time Offset", "Resource Usage Type", "Variant Code", "Installed in Line No_", "Installed in Item No_", mod_de)
    select "timestamp", "Parent Item No_", "Line No_", "Type", "No_", "Description", "Unit of Measure Code", "Quantity per", "Position", "Position 2",
            "Position 3", "Machine No_", "Lead-Time Offset", "Resource Usage Type", "Variant Code", "Installed in Line No_", "Installed in Item No_", mod_de
    from nav.tbl_int_bom_component_load;

    truncate table nav.tbl_int_bom_component_load;   
end;
$$ language plpgsql;

/* 0006.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_production_order_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_production_order_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_production_order'), 0);

    delete from nav.tbl_int_production_order as a
    where a."timestamp" > _rvers;

    insert into nav.tbl_int_production_order as t ("timestamp", "Status", "No_", "Description", "Search Description", "Description 2", "Creation Date", "Last Date Modified", "Source Type", "Source No_",
                                                "Routing No_", "Inventory Posting Group", "Gen_ Prod_ Posting Group", "Gen_ Bus_ Posting Group", "Starting Time", "Starting Date", "Ending Time",
                                                "Ending Date", "Due Date", "Finished Date", "Blocked", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Location Code", "Bin Code",
                                                "Replan Ref_ No_", "Replan Ref_ Status", "Low-Level Code", "Quantity", "Unit Cost", "Cost Amount", "No_ Series", "Planned Order No_",
                                                "Firm Planned Order No_", "Simulated Order No_", "Starting Date-Time", "Ending Date-Time", "Dimension Set ID", "Assigned User ID", "Data Primei Planificari",
                                                "Linked-to Sales Order", "Linked-to Sales Order Line", "Prod_ Order Finished", "Consumption", "Responsability Center", "Responsability Center 2",
                                                "All Resp_ Centers", "Observation", "Print", "Released Date", mod_de)
    select "timestamp", "Status", "No_", "Description", "Search Description", "Description 2", "Creation Date", "Last Date Modified", "Source Type", "Source No_",
            "Routing No_", "Inventory Posting Group", "Gen_ Prod_ Posting Group", "Gen_ Bus_ Posting Group", "Starting Time", "Starting Date", "Ending Time",
            "Ending Date", "Due Date", "Finished Date", "Blocked", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Location Code", "Bin Code",
            "Replan Ref_ No_", "Replan Ref_ Status", "Low-Level Code", "Quantity", "Unit Cost", "Cost Amount", "No_ Series", "Planned Order No_",
            "Firm Planned Order No_", "Simulated Order No_", "Starting Date-Time", "Ending Date-Time", "Dimension Set ID", "Assigned User ID", "Data Primei Planificari",
            "Linked-to Sales Order", "Linked-to Sales Order Line", "Prod_ Order Finished", "Consumption", "Responsability Center", "Responsability Center 2",
            "All Resp_ Centers", "Observation", "Print", "Released Date", mod_de
    from nav.tbl_int_production_order_load
    on conflict on constraint tbl_int_production_order_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Status" = excluded."Status",
        "Description" = excluded."Description",
        "Search Description" = excluded."Search Description",
        "Description 2" = excluded."Description 2",
        "Creation Date" = excluded."Creation Date",
        "Last Date Modified" = excluded."Last Date Modified",
        "Source Type" = excluded."Source Type",
        "Source No_" = excluded."Source No_",
        "Routing No_" = excluded."Routing No_",
        "Inventory Posting Group" = excluded."Inventory Posting Group",
        "Gen_ Prod_ Posting Group" = excluded."Gen_ Prod_ Posting Group",
        "Gen_ Bus_ Posting Group" = excluded."Gen_ Bus_ Posting Group",
        "Starting Time" = excluded."Starting Time",
        "Starting Date" = excluded."Starting Date",
        "Ending Time" = excluded."Ending Time",
        "Ending Date" = excluded."Ending Date",
        "Due Date" = excluded."Due Date",
        "Finished Date" = excluded."Finished Date",
        "Blocked" = excluded."Blocked",
        "Shortcut Dimension 1 Code" = excluded."Shortcut Dimension 1 Code",
        "Shortcut Dimension 2 Code" = excluded."Shortcut Dimension 2 Code",
        "Location Code" = excluded."Location Code",
        "Bin Code" = excluded."Bin Code",
        "Replan Ref_ No_" = excluded."Replan Ref_ No_",
        "Replan Ref_ Status" = excluded."Replan Ref_ Status",
        "Low-Level Code" = excluded."Low-Level Code",
        "Quantity" = excluded."Quantity",
        "Unit Cost" = excluded."Unit Cost",
        "Cost Amount" = excluded."Cost Amount",
        "No_ Series" = excluded."No_ Series",
        "Planned Order No_" = excluded."Planned Order No_",
        "Firm Planned Order No_" = excluded."Firm Planned Order No_",
        "Simulated Order No_" = excluded."Simulated Order No_",
        "Starting Date-Time" = excluded."Starting Date-Time",
        "Ending Date-Time" = excluded."Ending Date-Time",
        "Dimension Set ID" = excluded."Dimension Set ID",
        "Assigned User ID" = excluded."Assigned User ID",
        "Data Primei Planificari" = excluded."Data Primei Planificari",
        "Linked-to Sales Order" = excluded."Linked-to Sales Order",
        "Linked-to Sales Order Line" = excluded."Linked-to Sales Order Line",
        "Prod_ Order Finished" = excluded."Prod_ Order Finished",
        "Consumption" = excluded."Consumption",
        "Responsability Center" = excluded."Responsability Center",
        "Responsability Center 2" = excluded."Responsability Center 2",
        "All Resp_ Centers" = excluded."All Resp_ Centers",
        "Observation" = excluded."Observation",
        "Print" = excluded."Print",
        "Released Date" = excluded."Released Date",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_production_order_load;
end;
$$ language plpgsql;

/* 0006.02 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_prod_order_line_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_prod_order_line_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_production_order'), 0);

    delete from nav.tbl_int_prod_order_line as a
    using nav.tbl_int_production_order as b
    where a."Status" = b."Status" and a."Prod_ Order No_" = b."No_" and b."timestamp" > _rvers;

    insert into nav.tbl_int_prod_order_line as t ("timestamp", "Status", "Prod_ Order No_", "Line No_", "Item No_", "Variant Code", "Description", "Description 2",
                                                    "Location Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Bin Code", "Quantity", "Finished Quantity",
                                                    "Remaining Quantity", "Scrap _", "Due Date", "Starting Date", "Starting Time", "Ending Date", "Ending Time",
                                                    "Planning Level Code", "Priority", "Production BOM No_", "Routing No_", "Inventory Posting Group", "Routing Reference No_",
                                                    "Unit Cost", "Cost Amount", "Unit of Measure Code", "Quantity (Base)", "Finished Qty_ (Base)", "Remaining Qty_ (Base)",
                                                    "Starting Date-Time", "Ending Date-Time", "Dimension Set ID", "Cost Amount (ACY)", "Unit Cost (ACY)", "Production BOM Version Code",
                                                    "Routing Version Code", "Routing Type", "Qty_ per Unit of Measure", "MPS Order", "Planning Flexibility", "Indirect Cost _",
                                                    "Overhead Rate", "Responsability Center", "Confim Production date", mod_de)
    select "timestamp", "Status", "Prod_ Order No_", "Line No_", "Item No_", "Variant Code", "Description", "Description 2",
            "Location Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Bin Code", "Quantity", "Finished Quantity",
            "Remaining Quantity", "Scrap _", "Due Date", "Starting Date", "Starting Time", "Ending Date", "Ending Time",
            "Planning Level Code", "Priority", "Production BOM No_", "Routing No_", "Inventory Posting Group", "Routing Reference No_",
            "Unit Cost", "Cost Amount", "Unit of Measure Code", "Quantity (Base)", "Finished Qty_ (Base)", "Remaining Qty_ (Base)",
            "Starting Date-Time", "Ending Date-Time", "Dimension Set ID", "Cost Amount (ACY)", "Unit Cost (ACY)", "Production BOM Version Code",
            "Routing Version Code", "Routing Type", "Qty_ per Unit of Measure", "MPS Order", "Planning Flexibility", "Indirect Cost _",
            "Overhead Rate", "Responsability Center", "Confim Production date", mod_de
    from nav.tbl_int_prod_order_line_load
    on conflict on constraint tbl_int_prod_order_line_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Status" = excluded."Status",
        "Item No_" = excluded."Item No_",
        "Variant Code" = excluded."Variant Code",
        "Description" = excluded."Description",
        "Description 2" = excluded."Description 2",
        "Location Code" = excluded."Location Code",
        "Shortcut Dimension 1 Code" = excluded."Shortcut Dimension 1 Code",
        "Shortcut Dimension 2 Code" = excluded."Shortcut Dimension 2 Code",
        "Bin Code" = excluded."Bin Code",
        "Quantity" = excluded."Quantity",
        "Finished Quantity" = excluded."Finished Quantity",
        "Remaining Quantity" = excluded."Remaining Quantity",
        "Scrap _" = excluded."Scrap _",
        "Due Date" = excluded."Due Date",
        "Starting Date" = excluded."Starting Date",
        "Starting Time" = excluded."Starting Time",
        "Ending Date" = excluded."Ending Date",
        "Ending Time" = excluded."Ending Time",
        "Planning Level Code" = excluded."Planning Level Code",
        "Priority" = excluded."Priority",
        "Production BOM No_" = excluded."Production BOM No_",
        "Routing No_" = excluded."Routing No_",
        "Inventory Posting Group" = excluded."Inventory Posting Group",
        "Routing Reference No_" = excluded."Routing Reference No_",
        "Unit Cost" = excluded."Unit Cost",
        "Cost Amount" = excluded."Cost Amount",
        "Unit of Measure Code" = excluded."Unit of Measure Code",
        "Quantity (Base)" = excluded."Quantity (Base)",
        "Finished Qty_ (Base)" = excluded."Finished Qty_ (Base)",
        "Remaining Qty_ (Base)" = excluded."Remaining Qty_ (Base)",
        "Starting Date-Time" = excluded."Starting Date-Time",
        "Ending Date-Time" = excluded."Ending Date-Time",
        "Dimension Set ID" = excluded."Dimension Set ID",
        "Cost Amount (ACY)" = excluded."Cost Amount (ACY)",
        "Unit Cost (ACY)" = excluded."Unit Cost (ACY)",
        "Production BOM Version Code" = excluded."Production BOM Version Code",
        "Routing Version Code" = excluded."Routing Version Code",
        "Routing Type" = excluded."Routing Type",
        "Qty_ per Unit of Measure" = excluded."Qty_ per Unit of Measure",
        "MPS Order" = excluded."MPS Order",
        "Planning Flexibility" = excluded."Planning Flexibility",
        "Indirect Cost _" = excluded."Indirect Cost _",
        "Overhead Rate" = excluded."Overhead Rate",
        "Responsability Center" = excluded."Responsability Center",
        "Confim Production date" = excluded."Confim Production date",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_prod_order_line_load;
end;
$$ language plpgsql;

/* 0006.03 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_prod_order_component_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_prod_order_component_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_production_order'), 0);

    delete from nav.tbl_int_prod_order_component as a
    using nav.tbl_int_production_order as b
    where a."Status" = b."Status" and a."Prod_ Order No_" = b."No_" and b."timestamp" > _rvers;

    insert into nav.tbl_int_prod_order_component as t ("timestamp", "Status", "Prod_ Order No_", "Prod_ Order Line No_", "Line No_", "Item No_", "Description",
                                                        "Unit of Measure Code", "Quantity", "Position", "Position 2", "Position 3", "Lead-Time Offset", "Routing Link Code",
                                                        "Scrap _", "Variant Code", "Expected Quantity", "Remaining Quantity", "Flushing Method", "Location Code",
                                                        "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Bin Code", "Supplied-by Line No_", "Planning Level Code",
                                                        "Item Low-Level Code", "Length", "Width", "Weight", "Depth", "Calculation Formula", "Quantity per", "Unit Cost",
                                                        "Cost Amount", "Due Date", "Due Time", "Qty_ per Unit of Measure", "Remaining Qty_ (Base)", "Quantity (Base)",
                                                        "Expected Qty_ (Base)", "Due Date-Time", "Dimension Set ID", "Original Item No_", "Original Variant Code",
                                                        "Qty_ Picked", "Qty_ Picked (Base)", "Completely Picked", "Direct Unit Cost", "Indirect Cost _", "Overhead Rate",
                                                        "Direct Cost Amount", "Overhead Amount", "Reserv semif", "BOM Quantity per", mod_de)
    select "timestamp", "Status", "Prod_ Order No_", "Prod_ Order Line No_", "Line No_", "Item No_", "Description",
            "Unit of Measure Code", "Quantity", "Position", "Position 2", "Position 3", "Lead-Time Offset", "Routing Link Code",
            "Scrap _", "Variant Code", "Expected Quantity", "Remaining Quantity", "Flushing Method", "Location Code",
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Bin Code", "Supplied-by Line No_", "Planning Level Code",
            "Item Low-Level Code", "Length", "Width", "Weight", "Depth", "Calculation Formula", "Quantity per", "Unit Cost",
            "Cost Amount", "Due Date", "Due Time", "Qty_ per Unit of Measure", "Remaining Qty_ (Base)", "Quantity (Base)",
            "Expected Qty_ (Base)", "Due Date-Time", "Dimension Set ID", "Original Item No_", "Original Variant Code",
            "Qty_ Picked", "Qty_ Picked (Base)", "Completely Picked", "Direct Unit Cost", "Indirect Cost _", "Overhead Rate",
            "Direct Cost Amount", "Overhead Amount", "Reserv semif", "BOM Quantity per", mod_de
    from nav.tbl_int_prod_order_component_load
    on conflict on constraint tbl_int_prod_order_component_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Status" = excluded."Status",
        "Item No_" = excluded."Item No_",
        "Description" = excluded."Description",
        "Unit of Measure Code" = excluded."Unit of Measure Code",
        "Quantity" = excluded."Quantity",
        "Position" = excluded."Position",
        "Position 2" = excluded."Position 2",
        "Position 3" = excluded."Position 3",
        "Lead-Time Offset" = excluded."Lead-Time Offset",
        "Routing Link Code" = excluded."Routing Link Code",
        "Scrap _" = excluded."Scrap _",
        "Variant Code" = excluded."Variant Code",
        "Expected Quantity" = excluded."Expected Quantity",
        "Remaining Quantity" = excluded."Remaining Quantity",
        "Flushing Method" = excluded."Flushing Method",
        "Location Code" = excluded."Location Code",
        "Shortcut Dimension 1 Code" = excluded."Shortcut Dimension 1 Code",
        "Shortcut Dimension 2 Code" = excluded."Shortcut Dimension 2 Code",
        "Bin Code" = excluded."Bin Code",
        "Supplied-by Line No_" = excluded."Supplied-by Line No_",
        "Planning Level Code" = excluded."Planning Level Code",
        "Item Low-Level Code" = excluded."Item Low-Level Code",
        "Length" = excluded."Length",
        "Width" = excluded."Width",
        "Weight" = excluded."Weight",
        "Depth" = excluded."Depth",
        "Calculation Formula" = excluded."Calculation Formula",
        "Quantity per" = excluded."Quantity per",
        "Unit Cost" = excluded."Unit Cost",
        "Cost Amount" = excluded."Cost Amount",
        "Due Date" = excluded."Due Date",
        "Due Time" = excluded."Due Time",
        "Qty_ per Unit of Measure" = excluded."Qty_ per Unit of Measure",
        "Remaining Qty_ (Base)" = excluded."Remaining Qty_ (Base)",
        "Quantity (Base)" = excluded."Quantity (Base)",
        "Expected Qty_ (Base)" = excluded."Expected Qty_ (Base)",
        "Due Date-Time" = excluded."Due Date-Time",
        "Dimension Set ID" = excluded."Dimension Set ID",
        "Original Item No_" = excluded."Original Item No_",
        "Original Variant Code" = excluded."Original Variant Code",
        "Qty_ Picked" = excluded."Qty_ Picked",
        "Qty_ Picked (Base)" = excluded."Qty_ Picked (Base)",
        "Completely Picked" = excluded."Completely Picked",
        "Direct Unit Cost" = excluded."Direct Unit Cost",
        "Indirect Cost _" = excluded."Indirect Cost _",
        "Overhead Rate" = excluded."Overhead Rate",
        "Direct Cost Amount" = excluded."Direct Cost Amount",
        "Overhead Amount" = excluded."Overhead Amount",
        "Reserv semif" = excluded."Reserv semif",
        "BOM Quantity per" = excluded."BOM Quantity per",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_prod_order_component_load;
end;
$$ language plpgsql;

/* 0006.04 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_prod_order_routing_line_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_prod_order_routing_line_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_production_order'), 0);

    delete from nav.tbl_int_prod_order_routing_line as a
    using nav.tbl_int_production_order as b
    where a."Status" = b."Status" and a."Prod_ Order No_" = b."No_" and b."timestamp" > _rvers;

    insert into nav.tbl_int_prod_order_routing_line as t ("timestamp", "Status", "Prod_ Order No_", "Routing Reference No_", "Routing No_", "Operation No_", "Next Operation No_",
                                                            "Previous Operation No_", "Type", "No_", "Work Center No_", "Work Center Group Code", "Description", "Setup Time",
                                                            "Run Time", "Wait Time", "Move Time", "Fixed Scrap Quantity", "Lot Size", "Scrap Factor _", "Setup Time Unit of Meas_ Code",
                                                            "Run Time Unit of Meas_ Code", "Wait Time Unit of Meas_ Code", "Move Time Unit of Meas_ Code", "Minimum Process Time",
                                                            "Maximum Process Time", "Concurrent Capacities", "Send-Ahead Quantity", "Routing Link Code", "Standard Task Code", "Unit Cost per",
                                                            "Recalculate", "Sequence No_ (Forward)", "Sequence No_ (Backward)", "Fixed Scrap Qty_ (Accum_)", "Scrap Factor _ (Accumulated)",
                                                            "Sequence No_ (Actual)", "Direct Unit Cost", "Indirect Cost _", "Overhead Rate", "Starting Time", "Starting Date", "Ending Time",
                                                            "Ending Date", "Unit Cost Calculation", "Input Quantity", "Critical Path", "Routing Status", "Flushing Method", "Expected Operation Cost Amt_",
                                                            "Expected Capacity Need", "Expected Capacity Ovhd_ Cost", "Starting Date-Time", "Ending Date-Time", "Schedule Manually", "Location Code",
                                                            "Open Shop Floor Bin Code", "To-Production Bin Code", "From-Production Bin Code", "Seq", "No_of Workers", "Estim Machine Time", "Estim Workers Time",
                                                            "Description 2", "DR Run Time", "Net Run Time", "Machine Efficiency (_)", "Routing Version Code", mod_de)
    select "timestamp", "Status", "Prod_ Order No_", "Routing Reference No_", "Routing No_", "Operation No_", "Next Operation No_",
            "Previous Operation No_", "Type", "No_", "Work Center No_", "Work Center Group Code", "Description", "Setup Time",
            "Run Time", "Wait Time", "Move Time", "Fixed Scrap Quantity", "Lot Size", "Scrap Factor _", "Setup Time Unit of Meas_ Code",
            "Run Time Unit of Meas_ Code", "Wait Time Unit of Meas_ Code", "Move Time Unit of Meas_ Code", "Minimum Process Time",
            "Maximum Process Time", "Concurrent Capacities", "Send-Ahead Quantity", "Routing Link Code", "Standard Task Code", "Unit Cost per",
            "Recalculate", "Sequence No_ (Forward)", "Sequence No_ (Backward)", "Fixed Scrap Qty_ (Accum_)", "Scrap Factor _ (Accumulated)",
            "Sequence No_ (Actual)", "Direct Unit Cost", "Indirect Cost _", "Overhead Rate", "Starting Time", "Starting Date", "Ending Time",
            "Ending Date", "Unit Cost Calculation", "Input Quantity", "Critical Path", "Routing Status", "Flushing Method", "Expected Operation Cost Amt_",
            "Expected Capacity Need", "Expected Capacity Ovhd_ Cost", "Starting Date-Time", "Ending Date-Time", "Schedule Manually", "Location Code",
            "Open Shop Floor Bin Code", "To-Production Bin Code", "From-Production Bin Code", "Seq", "No_of Workers", "Estim Machine Time", "Estim Workers Time",
            "Description 2", "DR Run Time", "Net Run Time", "Machine Efficiency (_)", "Routing Version Code", mod_de
    from nav.tbl_int_prod_order_routing_line_load
    on conflict on constraint tbl_int_prod_order_routing_line_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Status" = excluded."Status",
        "Next Operation No_" = excluded."Next Operation No_",
        "Previous Operation No_" = excluded."Previous Operation No_",
        "Type" = excluded."Type",
        "No_" = excluded."No_",
        "Work Center No_" = excluded."Work Center No_",
        "Work Center Group Code" = excluded."Work Center Group Code",
        "Description" = excluded."Description",
        "Setup Time" = excluded."Setup Time",
        "Run Time" = excluded."Run Time",
        "Wait Time" = excluded."Wait Time",
        "Move Time" = excluded."Move Time",
        "Fixed Scrap Quantity" = excluded."Fixed Scrap Quantity",
        "Lot Size" = excluded."Lot Size",
        "Scrap Factor _" = excluded."Scrap Factor _",
        "Setup Time Unit of Meas_ Code" = excluded."Setup Time Unit of Meas_ Code",
        "Run Time Unit of Meas_ Code" = excluded."Run Time Unit of Meas_ Code",
        "Wait Time Unit of Meas_ Code" = excluded."Wait Time Unit of Meas_ Code",
        "Move Time Unit of Meas_ Code" = excluded."Move Time Unit of Meas_ Code",
        "Minimum Process Time" = excluded."Minimum Process Time",
        "Maximum Process Time" = excluded."Maximum Process Time",
        "Concurrent Capacities" = excluded."Concurrent Capacities",
        "Send-Ahead Quantity" = excluded."Send-Ahead Quantity",
        "Routing Link Code" = excluded."Routing Link Code",
        "Standard Task Code" = excluded."Standard Task Code",
        "Unit Cost per" = excluded."Unit Cost per",
        "Recalculate" = excluded."Recalculate",
        "Sequence No_ (Forward)" = excluded."Sequence No_ (Forward)",
        "Sequence No_ (Backward)" = excluded."Sequence No_ (Backward)",
        "Fixed Scrap Qty_ (Accum_)" = excluded."Fixed Scrap Qty_ (Accum_)",
        "Scrap Factor _ (Accumulated)" = excluded."Scrap Factor _ (Accumulated)",
        "Sequence No_ (Actual)" = excluded."Sequence No_ (Actual)",
        "Direct Unit Cost" = excluded."Direct Unit Cost",
        "Indirect Cost _" = excluded."Indirect Cost _",
        "Overhead Rate" = excluded."Overhead Rate",
        "Starting Time" = excluded."Starting Time",
        "Starting Date" = excluded."Starting Date",
        "Ending Time" = excluded."Ending Time",
        "Ending Date" = excluded."Ending Date",
        "Unit Cost Calculation" = excluded."Unit Cost Calculation",
        "Input Quantity" = excluded."Input Quantity",
        "Critical Path" = excluded."Critical Path",
        "Routing Status" = excluded."Routing Status",
        "Flushing Method" = excluded."Flushing Method",
        "Expected Operation Cost Amt_" = excluded."Expected Operation Cost Amt_",
        "Expected Capacity Need" = excluded."Expected Capacity Need",
        "Expected Capacity Ovhd_ Cost" = excluded."Expected Capacity Ovhd_ Cost",
        "Starting Date-Time" = excluded."Starting Date-Time",
        "Ending Date-Time" = excluded."Ending Date-Time",
        "Schedule Manually" = excluded."Schedule Manually",
        "Location Code" = excluded."Location Code",
        "Open Shop Floor Bin Code" = excluded."Open Shop Floor Bin Code",
        "To-Production Bin Code" = excluded."To-Production Bin Code",
        "From-Production Bin Code" = excluded."From-Production Bin Code",
        "Seq" = excluded."Seq",
        "No_of Workers" = excluded."No_of Workers",
        "Estim Machine Time" = excluded."Estim Machine Time",
        "Estim Workers Time" = excluded."Estim Workers Time",
        "Description 2" = excluded."Description 2",
        "DR Run Time" = excluded."DR Run Time",
        "Net Run Time" = excluded."Net Run Time",
        "Machine Efficiency (_)" = excluded."Machine Efficiency (_)",
        "Routing Version Code" = excluded."Routing Version Code",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_prod_order_routing_line_load;
end;
$$ language plpgsql;

/* 0006.05 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_prod_order_all_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_prod_order_all_merge_load()
as $$
declare
    _rvers bigint;
begin
    call nav.prc_prod_order_line_merge_load();
    call nav.prc_prod_order_component_merge_load();
    call nav.prc_prod_order_routing_line_merge_load();
    call nav.prc_production_order_merge_load(); /* trebuie sa fie ultima */

    _rvers := coalesce((select min("timestamp") from nav.tbl_int_production_order where "Status" != 4), 0) - 1; /* status 4 = Finished */

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_production_order', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0007.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_purchase_price_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_purchase_price_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_purchase_price as t ("timestamp", "Item No_", "Vendor No_", "Starting Date", "Currency Code", "Variant Code",
                                                "Unit of Measure Code", "Minimum Quantity", "Location Code", "Direct Unit Cost", "Ending Date", mod_de)
    select "timestamp", "Item No_", "Vendor No_", "Starting Date", "Currency Code", "Variant Code",
            "Unit of Measure Code", "Minimum Quantity", "Location Code", "Direct Unit Cost", "Ending Date", mod_de
    from nav.tbl_int_purchase_price_load
    on conflict on constraint tbl_int_purchase_price_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Direct Unit Cost" = excluded."Direct Unit Cost",
        "Ending Date" = excluded."Ending Date",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_purchase_price_load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_purchase_price as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_purchase_price', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0008.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_sales_price_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_sales_price_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_sales_price as t ("timestamp", "Item No_", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code","Minimum Quantity",
                                                "Unit Price", "Price Includes VAT", "Allow Invoice Disc_", "VAT Bus_ Posting Gr_ (Price)", "Ending Date", "Allow Line Disc_", mod_de)
    select "timestamp", "Item No_", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code","Minimum Quantity",
            "Unit Price", "Price Includes VAT", "Allow Invoice Disc_", "VAT Bus_ Posting Gr_ (Price)", "Ending Date", "Allow Line Disc_", mod_de
    from nav.tbl_int_sales_price_load
    on conflict on constraint tbl_int_sales_price_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Unit Price" = excluded."Unit Price",
        "Price Includes VAT" = excluded."Price Includes VAT",
        "Allow Invoice Disc_" = excluded."Allow Invoice Disc_",
        "VAT Bus_ Posting Gr_ (Price)" = excluded."VAT Bus_ Posting Gr_ (Price)",
        "Ending Date" = excluded."Ending Date",
        "Allow Line Disc_" = excluded."Allow Line Disc_",
        mod_de = excluded.mod_de
     where excluded."timestamp" > t."timestamp";

     truncate table nav.tbl_int_sales_price_load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_sales_price as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_sales_price', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0009.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_item_umas_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_item_umas_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_item_umas as t("timestamp", "Item No_", "Code", "Qty_ per Unit of Measure", "Length", "Width", "Height", "Cubage", "Weight", "Packaging Weight",
                                            "Expanded Polystyren weight", "Thinkness", "Box weight", "Stripe carton weight", "Paper weight", "Foil weight", "PFL_PAL_MDF weight", mod_de)
    select "timestamp", "Item No_", "Code", "Qty_ per Unit of Measure", "Length", "Width", "Height", "Cubage", "Weight", "Packaging Weight",
            "Expanded Polystyren weight", "Thinkness", "Box weight", "Stripe carton weight", "Paper weight", "Foil weight", "PFL_PAL_MDF weight", mod_de
    from nav.tbl_int_item_umas_load
    on conflict on constraint tbl_int_item_umas_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Qty_ per Unit of Measure" = excluded."Qty_ per Unit of Measure",
        "Length" = excluded."Length",
        "Width" = excluded."Width",
        "Height" = excluded."Height",
        "Cubage" = excluded."Cubage",
        "Weight" = excluded."Weight",
        "Packaging Weight" = excluded."Packaging Weight",
        "Expanded Polystyren weight" = excluded."Expanded Polystyren weight",
        "Thinkness" = excluded."Thinkness",
        "Box weight" = excluded."Box weight",
        "Stripe carton weight" = excluded."Stripe carton weight",
        "Paper weight" = excluded."Paper weight",
        "Foil weight" = excluded."Foil weight",
        "PFL_PAL_MDF weight" = excluded."PFL_PAL_MDF weight",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_item_umas_load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_item_umas as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_item_umas', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0010.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_item_ledger_entry_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_item_ledger_entry_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_item_ledger_entry as t ("timestamp", "Entry No_", "Item No_", "Posting Date", "Entry Type", "Source No_", "Document No_", "Description",
                                                    "Location Code", "Quantity", "Remaining Quantity", "Invoiced Quantity", "Applies-to Entry", "Open", "Global Dimension 1 Code",
                                                    "Global Dimension 2 Code", "Positive", "Source Type", "Drop Shipment", "Transaction Type", "Transport Method",
                                                    "Country_Region Code", "Entry_Exit Point", "Document Date", "External Document No_", "Area", "Transaction Specification",
                                                    "No_ Series", "Document Type", "Document Line No_", "Order Type", "Order No_", "Order Line No_", "Dimension Set ID", "Assemble to Order",
                                                    "Job No_", "Job Task No_", "Job Purchase", "Variant Code", "Qty_ per Unit of Measure", "Unit of Measure Code", "Derived from Blanket Order",
                                                    "Cross-Reference No_", "Originally Ordered No_", "Originally Ordered Var_ Code", "Out-of-Stock Substitution", "Item Category Code", "Nonstock",
                                                    "Purchasing Code", "Product Group Code", "Completely Invoiced", "Last Invoice Date", "Applied Entry to Adjust", "Correction",
                                                    "Shipped Qty_ Not Returned", "Prod_ Order Comp_ Line No_", "Serial No_", "Lot No_", "Warranty Date", "Expiration Date", "Item Tracking",
                                                    "Return Reason Code", "Discount Reason Code", "Order Advertising", "EU 3-Party Trade", "Tariff No_", "Net Weight", "Country_Region of Origin Code",
                                                    "Intrastat Transaction", "Shipment Method Code", "Custom Invoice No_", "No_ Of Workers", "Workers Qty_", "Employee No_", mod_de)
    select "timestamp", "Entry No_", "Item No_", "Posting Date", "Entry Type", "Source No_", "Document No_", "Description",
            "Location Code", "Quantity", "Remaining Quantity", "Invoiced Quantity", "Applies-to Entry", "Open", "Global Dimension 1 Code",
            "Global Dimension 2 Code", "Positive", "Source Type", "Drop Shipment", "Transaction Type", "Transport Method",
            "Country_Region Code", "Entry_Exit Point", "Document Date", "External Document No_", "Area", "Transaction Specification",
            "No_ Series", "Document Type", "Document Line No_", "Order Type", "Order No_", "Order Line No_", "Dimension Set ID", "Assemble to Order",
            "Job No_", "Job Task No_", "Job Purchase", "Variant Code", "Qty_ per Unit of Measure", "Unit of Measure Code", "Derived from Blanket Order",
            "Cross-Reference No_", "Originally Ordered No_", "Originally Ordered Var_ Code", "Out-of-Stock Substitution", "Item Category Code", "Nonstock",
            "Purchasing Code", "Product Group Code", "Completely Invoiced", "Last Invoice Date", "Applied Entry to Adjust", "Correction",
            "Shipped Qty_ Not Returned", "Prod_ Order Comp_ Line No_", "Serial No_", "Lot No_", "Warranty Date", "Expiration Date", "Item Tracking",
            "Return Reason Code", "Discount Reason Code", "Order Advertising", "EU 3-Party Trade", "Tariff No_", "Net Weight", "Country_Region of Origin Code",
            "Intrastat Transaction", "Shipment Method Code", "Custom Invoice No_", "No_ Of Workers", "Workers Qty_", "Employee No_", mod_de
    from nav.tbl_int_item_ledger_entry_load
    on conflict on constraint tbl_int_item_ledger_entry_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Item No_" = excluded."Item No_",
        "Posting Date" = excluded."Posting Date",
        "Entry Type" = excluded."Entry Type",
        "Source No_" = excluded."Source No_",
        "Document No_" = excluded."Document No_",
        "Description" = excluded."Description",
        "Location Code" = excluded."Location Code",
        "Quantity" = excluded."Quantity",
        "Remaining Quantity" = excluded."Remaining Quantity",
        "Invoiced Quantity" = excluded."Invoiced Quantity",
        "Applies-to Entry" = excluded."Applies-to Entry",
        "Open" = excluded."Open",
        "Global Dimension 1 Code" = excluded."Global Dimension 1 Code",
        "Global Dimension 2 Code" = excluded."Global Dimension 2 Code",
        "Positive" = excluded."Positive",
        "Source Type" = excluded."Source Type",
        "Drop Shipment" = excluded."Drop Shipment",
        "Transaction Type" = excluded."Transaction Type",
        "Transport Method" = excluded."Transport Method",
        "Country_Region Code" = excluded."Country_Region Code",
        "Entry_Exit Point" = excluded."Entry_Exit Point",
        "Document Date" = excluded."Document Date",
        "External Document No_" = excluded."External Document No_",
        "Area" = excluded."Area",
        "Transaction Specification" = excluded."Transaction Specification",
        "No_ Series" = excluded."No_ Series",
        "Document Type" = excluded."Document Type",
        "Document Line No_" = excluded."Document Line No_",
        "Order Type" = excluded."Order Type",
        "Order No_" = excluded."Order No_",
        "Order Line No_" = excluded."Order Line No_",
        "Dimension Set ID" = excluded."Dimension Set ID",
        "Assemble to Order" = excluded."Assemble to Order",
        "Job No_" = excluded."Job No_",
        "Job Task No_" = excluded."Job Task No_",
        "Job Purchase" = excluded."Job Purchase",
        "Variant Code" = excluded."Variant Code",
        "Qty_ per Unit of Measure" = excluded."Qty_ per Unit of Measure",
        "Unit of Measure Code" = excluded."Unit of Measure Code",
        "Derived from Blanket Order" = excluded."Derived from Blanket Order",
        "Cross-Reference No_" = excluded."Cross-Reference No_",
        "Originally Ordered No_" = excluded."Originally Ordered No_",
        "Originally Ordered Var_ Code" = excluded."Originally Ordered Var_ Code",
        "Out-of-Stock Substitution" = excluded."Out-of-Stock Substitution",
        "Item Category Code" = excluded."Item Category Code",
        "Nonstock" = excluded."Nonstock",
        "Purchasing Code" = excluded."Purchasing Code",
        "Product Group Code" = excluded."Product Group Code",
        "Completely Invoiced" = excluded."Completely Invoiced",
        "Last Invoice Date" = excluded."Last Invoice Date",
        "Applied Entry to Adjust" = excluded."Applied Entry to Adjust",
        "Correction" = excluded."Correction",
        "Shipped Qty_ Not Returned" = excluded."Shipped Qty_ Not Returned",
        "Prod_ Order Comp_ Line No_" = excluded."Prod_ Order Comp_ Line No_",
        "Serial No_" = excluded."Serial No_",
        "Lot No_" = excluded."Lot No_",
        "Warranty Date" = excluded."Warranty Date",
        "Expiration Date" = excluded."Expiration Date",
        "Item Tracking" = excluded."Item Tracking",
        "Return Reason Code" = excluded."Return Reason Code",
        "Discount Reason Code" = excluded."Discount Reason Code",
        "Order Advertising" = excluded."Order Advertising",
        "EU 3-Party Trade" = excluded."EU 3-Party Trade",
        "Tariff No_" = excluded."Tariff No_",
        "Net Weight" = excluded."Net Weight",
        "Country_Region of Origin Code" = excluded."Country_Region of Origin Code",
        "Intrastat Transaction" = excluded."Intrastat Transaction",
        "Shipment Method Code" = excluded."Shipment Method Code",
        "Custom Invoice No_" = excluded."Custom Invoice No_",
        "No_ Of Workers" = excluded."No_ Of Workers",
        "Workers Qty_" = excluded."Workers Qty_",
        "Employee No_" = excluded."Employee No_",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_item_ledger_entry_load;

    _rvers := coalesce((select max(a."Entry No_") from nav.tbl_int_item_ledger_entry as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_item_ledger_entry', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0011.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_value_entry_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_value_entry_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_value_entry as t ("timestamp", "Entry No_", "Item No_", "Posting Date", "Item Ledger Entry Type", "Source No_", "Document No_", "Description",
                                            "Location Code", "Inventory Posting Group", "Source Posting Group", "Item Ledger Entry No_", "Valued Quantity", "Item Ledger Entry Quantity",
                                            "Invoiced Quantity", "Cost per Unit", "Sales Amount (Actual)", "Salespers__Purch_ Code", "Discount Amount", "User ID", "Source Code",
                                            "Applies-to Entry", "Global Dimension 1 Code", "Global Dimension 2 Code", "Source Type", "Cost Amount (Actual)", "Cost Posted to G_L",
                                            "Reason Code", "Drop Shipment", "Journal Batch Name", "Gen_ Bus_ Posting Group", "Gen_ Prod_ Posting Group", "Document Date", "External Document No_",
                                            "Cost Amount (Actual) (ACY)", "Cost Posted to G_L (ACY)", "Cost per Unit (ACY)", "Document Type", "Document Line No_", "Order Type", "Order No_",
                                            "Order Line No_", "Expected Cost", "Item Charge No_", "Valued By Average Cost", "Partial Revaluation", "Inventoriable", "Valuation Date", "Entry Type",
                                            "Variance Type", "Purchase Amount (Actual)", "Purchase Amount (Expected)", "Sales Amount (Expected)", "Cost Amount (Expected)", "Cost Amount (Non-Invtbl_)",
                                            "Cost Amount (Expected) (ACY)", "Cost Amount (Non-Invtbl_)(ACY)", "Expected Cost Posted to G_L", "Exp_ Cost Posted to G_L (ACY)", "Dimension Set ID",
                                            "Job No_", "Job Task No_", "Job Ledger Entry No_", "Variant Code", "Adjustment", "Average Cost Exception", "Capacity Ledger Entry No_", "Type", "No_",
                                            "Return Reason Code", "Order Advertising", "G_L Correction", "Incl_ in Intrastat Amount", "Incl_ in Intrastat Stat_ Value", "Custom Invoice No_",
                                            "Correction Cost", mod_de)
    select "timestamp", "Entry No_", "Item No_", "Posting Date", "Item Ledger Entry Type", "Source No_", "Document No_", "Description",
            "Location Code", "Inventory Posting Group", "Source Posting Group", "Item Ledger Entry No_", "Valued Quantity", "Item Ledger Entry Quantity",
            "Invoiced Quantity", "Cost per Unit", "Sales Amount (Actual)", "Salespers__Purch_ Code", "Discount Amount", "User ID", "Source Code",
            "Applies-to Entry", "Global Dimension 1 Code", "Global Dimension 2 Code", "Source Type", "Cost Amount (Actual)", "Cost Posted to G_L",
            "Reason Code", "Drop Shipment", "Journal Batch Name", "Gen_ Bus_ Posting Group", "Gen_ Prod_ Posting Group", "Document Date", "External Document No_",
            "Cost Amount (Actual) (ACY)", "Cost Posted to G_L (ACY)", "Cost per Unit (ACY)", "Document Type", "Document Line No_", "Order Type", "Order No_",
            "Order Line No_", "Expected Cost", "Item Charge No_", "Valued By Average Cost", "Partial Revaluation", "Inventoriable", "Valuation Date", "Entry Type",
            "Variance Type", "Purchase Amount (Actual)", "Purchase Amount (Expected)", "Sales Amount (Expected)", "Cost Amount (Expected)", "Cost Amount (Non-Invtbl_)",
            "Cost Amount (Expected) (ACY)", "Cost Amount (Non-Invtbl_)(ACY)", "Expected Cost Posted to G_L", "Exp_ Cost Posted to G_L (ACY)", "Dimension Set ID",
            "Job No_", "Job Task No_", "Job Ledger Entry No_", "Variant Code", "Adjustment", "Average Cost Exception", "Capacity Ledger Entry No_", "Type", "No_",
            "Return Reason Code", "Order Advertising", "G_L Correction", "Incl_ in Intrastat Amount", "Incl_ in Intrastat Stat_ Value", "Custom Invoice No_",
            "Correction Cost", mod_de
    from nav.tbl_int_value_entry_load
    on conflict on constraint tbl_int_value_entry_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Item No_" = excluded."Item No_",
        "Posting Date" = excluded."Posting Date",
        "Item Ledger Entry Type" = excluded."Item Ledger Entry Type",
        "Source No_" = excluded."Source No_",
        "Document No_" = excluded."Document No_",
        "Description" = excluded."Description",
        "Location Code" = excluded."Location Code",
        "Inventory Posting Group" = excluded."Inventory Posting Group",
        "Source Posting Group" = excluded."Source Posting Group",
        "Item Ledger Entry No_" = excluded."Item Ledger Entry No_",
        "Valued Quantity" = excluded."Valued Quantity",
        "Item Ledger Entry Quantity" = excluded."Item Ledger Entry Quantity",
        "Invoiced Quantity" = excluded."Invoiced Quantity",
        "Cost per Unit" = excluded."Cost per Unit",
        "Sales Amount (Actual)" = excluded."Sales Amount (Actual)",
        "Salespers__Purch_ Code" = excluded."Salespers__Purch_ Code",
        "Discount Amount" = excluded."Discount Amount",
        "User ID" = excluded."User ID",
        "Source Code" = excluded."Source Code",
        "Applies-to Entry" = excluded."Applies-to Entry",
        "Global Dimension 1 Code" = excluded."Global Dimension 1 Code",
        "Global Dimension 2 Code" = excluded."Global Dimension 2 Code",
        "Source Type" = excluded."Source Type",
        "Cost Amount (Actual)" = excluded."Cost Amount (Actual)",
        "Cost Posted to G_L" = excluded."Cost Posted to G_L",
        "Reason Code" = excluded."Reason Code",
        "Drop Shipment" = excluded."Drop Shipment",
        "Journal Batch Name" = excluded."Journal Batch Name",
        "Gen_ Bus_ Posting Group" = excluded."Gen_ Bus_ Posting Group",
        "Gen_ Prod_ Posting Group" = excluded."Gen_ Prod_ Posting Group",
        "Document Date" = excluded."Document Date",
        "External Document No_" = excluded."External Document No_",
        "Cost Amount (Actual) (ACY)" = excluded."Cost Amount (Actual) (ACY)",
        "Cost Posted to G_L (ACY)" = excluded."Cost Posted to G_L (ACY)",
        "Cost per Unit (ACY)" = excluded."Cost per Unit (ACY)",
        "Document Type" = excluded."Document Type",
        "Document Line No_" = excluded."Document Line No_",
        "Order Type" = excluded."Order Type",
        "Order No_" = excluded."Order No_",
        "Order Line No_" = excluded."Order Line No_",
        "Expected Cost" = excluded."Expected Cost",
        "Item Charge No_" = excluded."Item Charge No_",
        "Valued By Average Cost" = excluded."Valued By Average Cost",
        "Partial Revaluation" = excluded."Partial Revaluation",
        "Inventoriable" = excluded."Inventoriable",
        "Valuation Date" = excluded."Valuation Date",
        "Entry Type" = excluded."Entry Type",
        "Variance Type" = excluded."Variance Type",
        "Purchase Amount (Actual)" = excluded."Purchase Amount (Actual)",
        "Purchase Amount (Expected)" = excluded."Purchase Amount (Expected)",
        "Sales Amount (Expected)" = excluded."Sales Amount (Expected)",
        "Cost Amount (Expected)" = excluded."Cost Amount (Expected)",
        "Cost Amount (Non-Invtbl_)" = excluded."Cost Amount (Non-Invtbl_)",
        "Cost Amount (Expected) (ACY)" = excluded."Cost Amount (Expected) (ACY)",
        "Cost Amount (Non-Invtbl_)(ACY)" = excluded."Cost Amount (Non-Invtbl_)(ACY)",
        "Expected Cost Posted to G_L" = excluded."Expected Cost Posted to G_L",
        "Exp_ Cost Posted to G_L (ACY)" = excluded."Exp_ Cost Posted to G_L (ACY)",
        "Dimension Set ID" = excluded."Dimension Set ID",
        "Job No_" = excluded."Job No_",
        "Job Task No_" = excluded."Job Task No_",
        "Job Ledger Entry No_" = excluded."Job Ledger Entry No_",
        "Variant Code" = excluded."Variant Code",
        "Adjustment" = excluded."Adjustment",
        "Average Cost Exception" = excluded."Average Cost Exception",
        "Capacity Ledger Entry No_" = excluded."Capacity Ledger Entry No_",
        "Type" = excluded."Type",
        "No_" = excluded."No_",
        "Return Reason Code" = excluded."Return Reason Code",
        "Order Advertising" = excluded."Order Advertising",
        "G_L Correction" = excluded."G_L Correction",
        "Incl_ in Intrastat Amount" = excluded."Incl_ in Intrastat Amount",
        "Incl_ in Intrastat Stat_ Value" = excluded."Incl_ in Intrastat Stat_ Value",
        "Custom Invoice No_" = excluded."Custom Invoice No_",
        "Correction Cost" = excluded."Correction Cost",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_value_entry_load;

    _rvers := coalesce((select max(a."Entry No_") from nav.tbl_int_value_entry as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_value_entry', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0012.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_customer_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_customer_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_customer as t ("timestamp", "No_", "Name", "Search Name", "Name 2", "Address", "Address 2", "City", "Contact", "Phone No_", "Telex No_",
                                        "Document Sending Profile", "Our Account No_", "Territory Code", "Global Dimension 1 Code", "Global Dimension 2 Code",
                                        "Chain Name", "Budgeted Amount", "Credit Limit (LCY)", "Customer Posting Group", "Currency Code", "Customer Price Group",
                                        "Language Code", "Statistics Group", "Payment Terms Code", "Fin_ Charge Terms Code", "Salesperson Code", "Shipment Method Code",
                                        "Shipping Agent Code", "Place of Export", "Invoice Disc_ Code", "Customer Disc_ Group", "Country_Region Code", "Collection Method",
                                        "Amount", "Blocked", "Invoice Copies", "Last Statement No_", "Print Statements", "Bill-to Customer No_", "Priority",
                                        "Payment Method Code", "Last Date Modified", "Application Method", "Prices Including VAT", "Location Code", "Fax No_",
                                        "Telex Answer Back", "VAT Registration No_", "Combine Shipments", "Gen_ Bus_ Posting Group", "GLN", "Post Code",
                                        "County", "E-Mail", "Home Page", "Reminder Terms Code", "No_ Series", "Tax Area Code", "Tax Liable", "VAT Bus_ Posting Group",
                                        "Reserve", "Block Payment Tolerance", "IC Partner Code", "Prepayment _", "Partner Type", "Image", "Preferred Bank Account Code",
                                        "Cash Flow Payment Terms Code", "Primary Contact No_", "Responsibility Center", "Shipping Advice", "Shipping Time",
                                        "Shipping Agent Service Code", "Service Zone Code", "Allow Line Disc_", "Base Calendar Code", "Copy Sell-to Addr_ to Qte From",
                                        "GPS1 latitude", "GPS2 longitude", "Delivery Zone", "Customer Type", "Store Code", "Customer Code PGS", "Email", "Insigna",
                                        "Posted Invoice Nos_", "Posted Credit Memo Nos_", "Posted Shipment Nos_", "Posted Return Shipment Nos_", "Ship-to PGS", "Customer no_ 2",
                                        "Client de magazin", "Cod IRIS", "Phone No_2", "Customer commercial disc_", "Invoice per Sales Order", "Data inceput Split TVA",
                                        "Data inceput TVA de plata", "Data inceput TVA", "Data sfarsit TVA", "Data sfarsit TVA de plata", "Inactiv", "Data inactivare",
                                        "Data Reactivare", "Data anulare Split TVA", "VAT to Pay", "Registru Plati Defalcate", "Lant", "Sublant", "Aderent No_",
                                        "Manual Tour Invoice", "Franco Limit No_", "Default Bank Account Code", "Customer Contract No_", "Not VAT Registered", "Registration No_",
                                        "Commerce Trade No_", "Transaction Type", "Transaction Specification", "Transport Method", "Index Invoice Exchage Rate", "Organization type",
                                        "Tip Partener", "Cod Judet D394", "Budget category", "Network", mod_de)
    select "timestamp", "No_", "Name", "Search Name", "Name 2", "Address", "Address 2", "City", "Contact", "Phone No_", "Telex No_",
            "Document Sending Profile", "Our Account No_", "Territory Code", "Global Dimension 1 Code", "Global Dimension 2 Code",
            "Chain Name", "Budgeted Amount", "Credit Limit (LCY)", "Customer Posting Group", "Currency Code", "Customer Price Group",
            "Language Code", "Statistics Group", "Payment Terms Code", "Fin_ Charge Terms Code", "Salesperson Code", "Shipment Method Code",
            "Shipping Agent Code", "Place of Export", "Invoice Disc_ Code", "Customer Disc_ Group", "Country_Region Code", "Collection Method",
            "Amount", "Blocked", "Invoice Copies", "Last Statement No_", "Print Statements", "Bill-to Customer No_", "Priority",
            "Payment Method Code", "Last Date Modified", "Application Method", "Prices Including VAT", "Location Code", "Fax No_",
            "Telex Answer Back", "VAT Registration No_", "Combine Shipments", "Gen_ Bus_ Posting Group", "GLN", "Post Code",
            "County", "E-Mail", "Home Page", "Reminder Terms Code", "No_ Series", "Tax Area Code", "Tax Liable", "VAT Bus_ Posting Group",
            "Reserve", "Block Payment Tolerance", "IC Partner Code", "Prepayment _", "Partner Type", "Image", "Preferred Bank Account Code",
            "Cash Flow Payment Terms Code", "Primary Contact No_", "Responsibility Center", "Shipping Advice", "Shipping Time",
            "Shipping Agent Service Code", "Service Zone Code", "Allow Line Disc_", "Base Calendar Code", "Copy Sell-to Addr_ to Qte From",
            "GPS1 latitude", "GPS2 longitude", "Delivery Zone", "Customer Type", "Store Code", "Customer Code PGS", "Email", "Insigna",
            "Posted Invoice Nos_", "Posted Credit Memo Nos_", "Posted Shipment Nos_", "Posted Return Shipment Nos_", "Ship-to PGS", "Customer no_ 2",
            "Client de magazin", "Cod IRIS", "Phone No_2", "Customer commercial disc_", "Invoice per Sales Order", "Data inceput Split TVA",
            "Data inceput TVA de plata", "Data inceput TVA", "Data sfarsit TVA", "Data sfarsit TVA de plata", "Inactiv", "Data inactivare",
            "Data Reactivare", "Data anulare Split TVA", "VAT to Pay", "Registru Plati Defalcate", "Lant", "Sublant", "Aderent No_",
            "Manual Tour Invoice", "Franco Limit No_", "Default Bank Account Code", "Customer Contract No_", "Not VAT Registered", "Registration No_",
            "Commerce Trade No_", "Transaction Type", "Transaction Specification", "Transport Method", "Index Invoice Exchage Rate", "Organization type",
            "Tip Partener", "Cod Judet D394", "Budget category", "Network", mod_de
    from nav.tbl_int_customer_load
    on conflict on constraint tbl_int_customer_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Name" = excluded."Name",
        "Search Name" = excluded."Search Name",
        "Name 2" = excluded."Name 2",
        "Address" = excluded."Address",
        "Address 2" = excluded."Address 2",
        "City" = excluded."City",
        "Contact" = excluded."Contact",
        "Phone No_" = excluded."Phone No_",
        "Telex No_" = excluded."Telex No_",
        "Document Sending Profile" = excluded."Document Sending Profile",
        "Our Account No_" = excluded."Our Account No_",
        "Territory Code" = excluded."Territory Code",
        "Global Dimension 1 Code" = excluded."Global Dimension 1 Code",
        "Global Dimension 2 Code" = excluded."Global Dimension 2 Code",
        "Chain Name" = excluded."Chain Name",
        "Budgeted Amount" = excluded."Budgeted Amount",
        "Credit Limit (LCY)" = excluded."Credit Limit (LCY)",
        "Customer Posting Group" = excluded."Customer Posting Group",
        "Currency Code" = excluded."Currency Code",
        "Customer Price Group" = excluded."Customer Price Group",
        "Language Code" = excluded."Language Code",
        "Statistics Group" = excluded."Statistics Group",
        "Payment Terms Code" = excluded."Payment Terms Code",
        "Fin_ Charge Terms Code" = excluded."Fin_ Charge Terms Code",
        "Salesperson Code" = excluded."Salesperson Code",
        "Shipment Method Code" = excluded."Shipment Method Code",
        "Shipping Agent Code" = excluded."Shipping Agent Code",
        "Place of Export" = excluded."Place of Export",
        "Invoice Disc_ Code" = excluded."Invoice Disc_ Code",
        "Customer Disc_ Group" = excluded."Customer Disc_ Group",
        "Country_Region Code" = excluded."Country_Region Code",
        "Collection Method" = excluded."Collection Method",
        "Amount" = excluded."Amount",
        "Blocked" = excluded."Blocked",
        "Invoice Copies" = excluded."Invoice Copies",
        "Last Statement No_" = excluded."Last Statement No_",
        "Print Statements" = excluded."Print Statements",
        "Bill-to Customer No_" = excluded."Bill-to Customer No_",
        "Priority" = excluded."Priority",
        "Payment Method Code" = excluded."Payment Method Code",
        "Last Date Modified" = excluded."Last Date Modified",
        "Application Method" = excluded."Application Method",
        "Prices Including VAT" = excluded."Prices Including VAT",
        "Location Code" = excluded."Location Code",
        "Fax No_" = excluded."Fax No_",
        "Telex Answer Back" = excluded."Telex Answer Back",
        "VAT Registration No_" = excluded."VAT Registration No_",
        "Combine Shipments" = excluded."Combine Shipments",
        "Gen_ Bus_ Posting Group" = excluded."Gen_ Bus_ Posting Group",
        "GLN" = excluded."GLN",
        "Post Code" = excluded."Post Code",
        "County" = excluded."County",
        "E-Mail" = excluded."E-Mail",
        "Home Page" = excluded."Home Page",
        "Reminder Terms Code" = excluded."Reminder Terms Code",
        "No_ Series" = excluded."No_ Series",
        "Tax Area Code" = excluded."Tax Area Code",
        "Tax Liable" = excluded."Tax Liable",
        "VAT Bus_ Posting Group" = excluded."VAT Bus_ Posting Group",
        "Reserve" = excluded."Reserve",
        "Block Payment Tolerance" = excluded."Block Payment Tolerance",
        "IC Partner Code" = excluded."IC Partner Code",
        "Prepayment _" = excluded."Prepayment _",
        "Partner Type" = excluded."Partner Type",
        "Image" = excluded."Image",
        "Preferred Bank Account Code" = excluded."Preferred Bank Account Code",
        "Cash Flow Payment Terms Code" = excluded."Cash Flow Payment Terms Code",
        "Primary Contact No_" = excluded."Primary Contact No_",
        "Responsibility Center" = excluded."Responsibility Center",
        "Shipping Advice" = excluded."Shipping Advice",
        "Shipping Time" = excluded."Shipping Time",
        "Shipping Agent Service Code" = excluded."Shipping Agent Service Code",
        "Service Zone Code" = excluded."Service Zone Code",
        "Allow Line Disc_" = excluded."Allow Line Disc_",
        "Base Calendar Code" = excluded."Base Calendar Code",
        "Copy Sell-to Addr_ to Qte From" = excluded."Copy Sell-to Addr_ to Qte From",
        "GPS1 latitude" = excluded."GPS1 latitude",
        "GPS2 longitude" = excluded."GPS2 longitude",
        "Delivery Zone" = excluded."Delivery Zone",
        "Customer Type" = excluded."Customer Type",
        "Store Code" = excluded."Store Code",
        "Customer Code PGS" = excluded."Customer Code PGS",
        "Email" = excluded."Email",
        "Insigna" = excluded."Insigna",
        "Posted Invoice Nos_" = excluded."Posted Invoice Nos_",
        "Posted Credit Memo Nos_" = excluded."Posted Credit Memo Nos_",
        "Posted Shipment Nos_" = excluded."Posted Shipment Nos_",
        "Posted Return Shipment Nos_" = excluded."Posted Return Shipment Nos_",
        "Ship-to PGS" = excluded."Ship-to PGS",
        "Customer no_ 2" = excluded."Customer no_ 2",
        "Client de magazin" = excluded."Client de magazin",
        "Cod IRIS" = excluded."Cod IRIS",
        "Phone No_2" = excluded."Phone No_2",
        "Customer commercial disc_" = excluded."Customer commercial disc_",
        "Invoice per Sales Order" = excluded."Invoice per Sales Order",
        "Data inceput Split TVA" = excluded."Data inceput Split TVA",
        "Data inceput TVA de plata" = excluded."Data inceput TVA de plata",
        "Data inceput TVA" = excluded."Data inceput TVA",
        "Data sfarsit TVA" = excluded."Data sfarsit TVA",
        "Data sfarsit TVA de plata" = excluded."Data sfarsit TVA de plata",
        "Inactiv" = excluded."Inactiv",
        "Data inactivare" = excluded."Data inactivare",
        "Data Reactivare" = excluded."Data Reactivare",
        "Data anulare Split TVA" = excluded."Data anulare Split TVA",
        "VAT to Pay" = excluded."VAT to Pay",
        "Registru Plati Defalcate" = excluded."Registru Plati Defalcate",
        "Lant" = excluded."Lant",
        "Sublant" = excluded."Sublant",
        "Aderent No_" = excluded."Aderent No_",
        "Manual Tour Invoice" = excluded."Manual Tour Invoice",
        "Franco Limit No_" = excluded."Franco Limit No_",
        "Default Bank Account Code" = excluded."Default Bank Account Code",
        "Customer Contract No_" = excluded."Customer Contract No_",
        "Not VAT Registered" = excluded."Not VAT Registered",
        "Registration No_" = excluded."Registration No_",
        "Commerce Trade No_" = excluded."Commerce Trade No_",
        "Transaction Type" = excluded."Transaction Type",
        "Transaction Specification" = excluded."Transaction Specification",
        "Transport Method" = excluded."Transport Method",
        "Index Invoice Exchage Rate" = excluded."Index Invoice Exchage Rate",
        "Organization type" = excluded."Organization type",
        "Tip Partener" = excluded."Tip Partener",
        "Cod Judet D394" = excluded."Cod Judet D394",
        "Budget category" = excluded."Budget category",
        "Network" = excluded."Network",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_customer_load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_customer as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_customer', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0013.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_customer_price_group_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_customer_price_group_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_customer_price_group as t ("timestamp", "Code", "Price Includes VAT", "Allow Invoice Disc_", "VAT Bus_ Posting Gr_ (Price)", "Description", "Allow Line Disc_",
                                                    "Pub Delivery Interval", "RDV Report text", "Std Delivery Interval", "EDI Posted Inv_ Export", "DESADV_req", "INVOIC_req", "ORDRSP_req",
                                                    "Tip rutare", "Invoice FTP link", "User FTP", "Password FTP", "RFA _", "Shipment FTP link", "PAR_BY", "Invoice Bank 2", mod_de)
    select "timestamp", "Code", "Price Includes VAT", "Allow Invoice Disc_", "VAT Bus_ Posting Gr_ (Price)", "Description", "Allow Line Disc_",
            "Pub Delivery Interval", "RDV Report text", "Std Delivery Interval", "EDI Posted Inv_ Export", "DESADV_req", "INVOIC_req", "ORDRSP_req",
            "Tip rutare", "Invoice FTP link", "User FTP", "Password FTP", "RFA _", "Shipment FTP link", "PAR_BY", "Invoice Bank 2", mod_de
    from nav.tbl_int_customer_price_group_load
    on conflict on constraint tbl_int_customer_price_group_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Price Includes VAT" = excluded."Price Includes VAT",
        "Allow Invoice Disc_" = excluded."Allow Invoice Disc_",
        "VAT Bus_ Posting Gr_ (Price)" = excluded."VAT Bus_ Posting Gr_ (Price)",
        "Description" = excluded."Description",
        "Allow Line Disc_" = excluded."Allow Line Disc_",
        "Pub Delivery Interval" = excluded."Pub Delivery Interval",
        "RDV Report text" = excluded."RDV Report text",
        "Std Delivery Interval" = excluded."Std Delivery Interval",
        "EDI Posted Inv_ Export" = excluded."EDI Posted Inv_ Export",
        "DESADV_req" = excluded."DESADV_req",
        "INVOIC_req" = excluded."INVOIC_req",
        "ORDRSP_req" = excluded."ORDRSP_req",
        "Tip rutare" = excluded."Tip rutare",
        "Invoice FTP link" = excluded."Invoice FTP link",
        "User FTP" = excluded."User FTP",
        "Password FTP" = excluded."Password FTP",
        "RFA _" = excluded."RFA _",
        "Shipment FTP link" = excluded."Shipment FTP link",
        "PAR_BY" = excluded."PAR_BY",
        "Invoice Bank 2" = excluded."Invoice Bank 2",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_customer_price_group_load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_customer_price_group as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_customer_price_group', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0014.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_warehouse_entry_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_warehouse_entry_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_warehouse_entry as t ("timestamp", "Entry No_", "Journal Batch Name", "Line No_", "Registering Date", "Location Code",
                                                "Zone Code", "Bin Code", "Description", "Item No_", "Quantity", "Qty_ (Base)", "Source Type",
                                                "Source Subtype", "Source No_", "Source Line No_", "Source Subline No_", "Source Document", "Source Code",
                                                "Reason Code", "No_ Series", "Bin Type Code", "Cubage", "Weight", "Journal Template Name", "Whse_ Document No_",
                                                "Whse_ Document Type", "Whse_ Document Line No_", "Entry Type", "Reference Document", "Reference No_", "User ID",
                                                "Variant Code", "Qty_ per Unit of Measure", "Unit of Measure Code", "Serial No_", "Lot No_", "Warranty Date",
                                                "Expiration Date", "Phys Invt Counting Period Code", "Phys Invt Counting Period Type", "Dedicated", "Pallet No_", mod_de)
    select "timestamp", "Entry No_", "Journal Batch Name", "Line No_", "Registering Date", "Location Code",
            "Zone Code", "Bin Code", "Description", "Item No_", "Quantity", "Qty_ (Base)", "Source Type",
            "Source Subtype", "Source No_", "Source Line No_", "Source Subline No_", "Source Document", "Source Code",
            "Reason Code", "No_ Series", "Bin Type Code", "Cubage", "Weight", "Journal Template Name", "Whse_ Document No_",
            "Whse_ Document Type", "Whse_ Document Line No_", "Entry Type", "Reference Document", "Reference No_", "User ID",
            "Variant Code", "Qty_ per Unit of Measure", "Unit of Measure Code", "Serial No_", "Lot No_", "Warranty Date",
            "Expiration Date", "Phys Invt Counting Period Code", "Phys Invt Counting Period Type", "Dedicated", "Pallet No_", mod_de
    from nav.tbl_int_warehouse_entry_load
    on conflict on constraint tbl_int_warehouse_entry_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Journal Batch Name" = excluded."Journal Batch Name",
        "Line No_" = excluded."Line No_",
        "Registering Date" = excluded."Registering Date",
        "Location Code" = excluded."Location Code",
        "Zone Code" = excluded."Zone Code",
        "Bin Code" = excluded."Bin Code",
        "Description" = excluded."Description",
        "Item No_" = excluded."Item No_",
        "Quantity" = excluded."Quantity",
        "Qty_ (Base)" = excluded."Qty_ (Base)",
        "Source Type" = excluded."Source Type",
        "Source Subtype" = excluded."Source Subtype",
        "Source No_" = excluded."Source No_",
        "Source Line No_" = excluded."Source Line No_",
        "Source Subline No_" = excluded."Source Subline No_",
        "Source Document" = excluded."Source Document",
        "Source Code" = excluded."Source Code",
        "Reason Code" = excluded."Reason Code",
        "No_ Series" = excluded."No_ Series",
        "Bin Type Code" = excluded."Bin Type Code",
        "Cubage" = excluded."Cubage",
        "Weight" = excluded."Weight",
        "Journal Template Name" = excluded."Journal Template Name",
        "Whse_ Document No_" = excluded."Whse_ Document No_",
        "Whse_ Document Type" = excluded."Whse_ Document Type",
        "Whse_ Document Line No_" = excluded."Whse_ Document Line No_",
        "Entry Type" = excluded."Entry Type",
        "Reference Document" = excluded."Reference Document",
        "Reference No_" = excluded."Reference No_",
        "User ID" = excluded."User ID",
        "Variant Code" = excluded."Variant Code",
        "Qty_ per Unit of Measure" = excluded."Qty_ per Unit of Measure",
        "Unit of Measure Code" = excluded."Unit of Measure Code",
        "Serial No_" = excluded."Serial No_",
        "Lot No_" = excluded."Lot No_",
        "Warranty Date" = excluded."Warranty Date",
        "Expiration Date" = excluded."Expiration Date",
        "Phys Invt Counting Period Code" = excluded."Phys Invt Counting Period Code",
        "Phys Invt Counting Period Type" = excluded."Phys Invt Counting Period Type",
        "Dedicated" = excluded."Dedicated",
        "Pallet No_" = excluded."Pallet No_",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_warehouse_entry_load;

    _rvers := coalesce((select max(a."Entry No_") from nav.tbl_int_warehouse_entry as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_warehouse_entry', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0015.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_change_log_entry_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_change_log_entry_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_change_log_entry as t ("timestamp", "Entry No_", "Date and Time", "Time", "User ID", "Table No_", "Field No_", "Type of Change", "Old Value",
                                                "New Value", "Primary Key", "Primary Key Field 1 No_", "Primary Key Field 1 Value", "Primary Key Field 2 No_",
                                                "Primary Key Field 2 Value", "Primary Key Field 3 No_", "Primary Key Field 3 Value", mod_de)
    select "timestamp", "Entry No_", "Date and Time", "Time", "User ID", "Table No_", "Field No_", "Type of Change", "Old Value",
            "New Value", "Primary Key", "Primary Key Field 1 No_", "Primary Key Field 1 Value", "Primary Key Field 2 No_",
            "Primary Key Field 2 Value", "Primary Key Field 3 No_", "Primary Key Field 3 Value", mod_de
    from nav.tbl_int_change_log_entry_load
    on conflict on constraint tbl_int_change_log_entry_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Date and Time" = excluded."Date and Time",
        "Time" = excluded."Time",
        "User ID" = excluded."User ID",
        "Table No_" = excluded."Table No_",
        "Field No_" = excluded."Field No_",
        "Type of Change" = excluded."Type of Change",
        "Old Value" = excluded."Old Value",
        "New Value" = excluded."New Value",
        "Primary Key" = excluded."Primary Key",
        "Primary Key Field 1 No_" = excluded."Primary Key Field 1 No_",
        "Primary Key Field 1 Value" = excluded."Primary Key Field 1 Value",
        "Primary Key Field 2 No_" = excluded."Primary Key Field 2 No_",
        "Primary Key Field 2 Value" = excluded."Primary Key Field 2 Value",
        "Primary Key Field 3 No_" = excluded."Primary Key Field 3 No_",
        "Primary Key Field 3 Value" = excluded."Primary Key Field 3 Value",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_change_log_entry_load;

    _rvers := coalesce((select max(a."Entry No_") from nav.tbl_int_change_log_entry as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_change_log_entry', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0016.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_capacity_ledger_entry_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_capacity_ledger_entry_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_capacity_ledger_entry as t ("timestamp", "Entry No_", "No_", "Posting Date", "Type", "Document No_", "Description", "Operation No_",
                                                        "Work Center No_", "Quantity", "Setup Time", "Run Time", "Stop Time", "Invoiced Quantity", "Output Quantity",
                                                        "Scrap Quantity", "Concurrent Capacity", "Cap_ Unit of Measure Code", "Qty_ per Cap_ Unit of Measure", "Global Dimension 1 Code",
                                                        "Global Dimension 2 Code", "Last Output Line", "Completely Invoiced", "Starting Time", "Ending Time", "Routing No_",
                                                        "Routing Reference No_", "Item No_", "Variant Code", "Unit of Measure Code", "Qty_ per Unit of Measure", "Document Date",
                                                        "External Document No_", "Stop Code", "Scrap Code", "Work Center Group Code", "Work Shift Code", "Subcontracting", "Order Type",
                                                        "Order No_", "Order Line No_", "Dimension Set ID", "No_ Of Workers", "Workers Qty_", "Employee No_", mod_de)
    select "timestamp", "Entry No_", "No_", "Posting Date", "Type", "Document No_", "Description", "Operation No_",
            "Work Center No_", "Quantity", "Setup Time", "Run Time", "Stop Time", "Invoiced Quantity", "Output Quantity",
            "Scrap Quantity", "Concurrent Capacity", "Cap_ Unit of Measure Code", "Qty_ per Cap_ Unit of Measure", "Global Dimension 1 Code",
            "Global Dimension 2 Code", "Last Output Line", "Completely Invoiced", "Starting Time", "Ending Time", "Routing No_",
            "Routing Reference No_", "Item No_", "Variant Code", "Unit of Measure Code", "Qty_ per Unit of Measure", "Document Date",
            "External Document No_", "Stop Code", "Scrap Code", "Work Center Group Code", "Work Shift Code", "Subcontracting", "Order Type",
            "Order No_", "Order Line No_", "Dimension Set ID", "No_ Of Workers", "Workers Qty_", "Employee No_", mod_de
    from nav.tbl_int_capacity_ledger_entry_load
    on conflict on constraint tbl_int_capacity_ledger_entry_pk do
    update set
        "timestamp" = excluded."timestamp",
        "No_" = excluded."No_",
        "Posting Date" = excluded."Posting Date",
        "Type" = excluded."Type",
        "Document No_" = excluded."Document No_",
        "Description" = excluded."Description",
        "Operation No_" = excluded."Operation No_",
        "Work Center No_" = excluded."Work Center No_",
        "Quantity" = excluded."Quantity",
        "Setup Time" = excluded."Setup Time",
        "Run Time" = excluded."Run Time",
        "Stop Time" = excluded."Stop Time",
        "Invoiced Quantity" = excluded."Invoiced Quantity",
        "Output Quantity" = excluded."Output Quantity",
        "Scrap Quantity" = excluded."Scrap Quantity",
        "Concurrent Capacity" = excluded."Concurrent Capacity",
        "Cap_ Unit of Measure Code" = excluded."Cap_ Unit of Measure Code",
        "Qty_ per Cap_ Unit of Measure" = excluded."Qty_ per Cap_ Unit of Measure",
        "Global Dimension 1 Code" = excluded."Global Dimension 1 Code",
        "Global Dimension 2 Code" = excluded."Global Dimension 2 Code",
        "Last Output Line" = excluded."Last Output Line",
        "Completely Invoiced" = excluded."Completely Invoiced",
        "Starting Time" = excluded."Starting Time",
        "Ending Time" = excluded."Ending Time",
        "Routing No_" = excluded."Routing No_",
        "Routing Reference No_" = excluded."Routing Reference No_",
        "Item No_" = excluded."Item No_",
        "Variant Code" = excluded."Variant Code",
        "Unit of Measure Code" = excluded."Unit of Measure Code",
        "Qty_ per Unit of Measure" = excluded."Qty_ per Unit of Measure",
        "Document Date" = excluded."Document Date",
        "External Document No_" = excluded."External Document No_",
        "Stop Code" = excluded."Stop Code",
        "Scrap Code" = excluded."Scrap Code",
        "Work Center Group Code" = excluded."Work Center Group Code",
        "Work Shift Code" = excluded."Work Shift Code",
        "Subcontracting" = excluded."Subcontracting",
        "Order Type" = excluded."Order Type",
        "Order No_" = excluded."Order No_",
        "Order Line No_" = excluded."Order Line No_",
        "Dimension Set ID" = excluded."Dimension Set ID",
        "No_ Of Workers" = excluded."No_ Of Workers",
        "Workers Qty_" = excluded."Workers Qty_",
        "Employee No_" = excluded."Employee No_",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_capacity_ledger_entry_load;

    _rvers := coalesce((select max(a."Entry No_") from nav.tbl_int_capacity_ledger_entry as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_capacity_ledger_entry', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0017.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_machine_prod_declar_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_machine_prod_declar_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_machine_prod_declar'), 0);

    delete from nav.tbl_int_machine_prod_declar as a
    where a."timestamp" > _rvers;

    insert into nav.tbl_int_machine_prod_declar as t ("timestamp", "Machine Center No_", "Date", "Work Shift", "Declaration Status", "Responsibility Center",
                                                    "Location Code", "Created By", "Validated By", "Employee No_", mod_de)
    select "timestamp", "Machine Center No_", "Date", "Work Shift", "Declaration Status", "Responsibility Center",
            "Location Code", "Created By", "Validated By", "Employee No_", mod_de
    from nav.tbl_int_machine_prod_declar_load
    on conflict on constraint tbl_int_machine_prod_declar_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Declaration Status" = excluded."Declaration Status",
        "Responsibility Center" = excluded."Responsibility Center",
        "Location Code" = excluded."Location Code",
        "Created By" = excluded."Created By",
        "Validated By" = excluded."Validated By",
        "Employee No_" = excluded."Employee No_",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_machine_prod_declar_load;
end;
$$ language plpgsql;

/* 0017.02 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_machine_prod_declar_line_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_machine_prod_declar_line_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_machine_prod_declar'), 0);

    delete from nav.tbl_int_machine_prod_declar_line as a
    using nav.tbl_int_machine_prod_declar as b
    where a."Machine Center No_" = b."Machine Center No_" and a."Date" = b."Date" and a."Work Shift" = b."Work Shift" and b."timestamp" > _rvers;

    insert into nav.tbl_int_machine_prod_declar_line as t ("timestamp", "Machine Center No_", "Date", "Work Shift", "Line No_", "Prod_ Order No_", "Prod_ Order Line",
                                                        "Routing No_", "Operation No_", "Prod_ Order Item No_", "Setup Start", "Setup End", "Run Start", "Run End",
                                                        "Runtime Min_", "Setup Time Min_", "Conf_ Qty_", "Scrap Qty_", "No_of Workers", "Time per Piece", "Scrap Code",
                                                        "Scrap Commets", "Repair Code", mod_de)
    select "timestamp", "Machine Center No_", "Date", "Work Shift", "Line No_", "Prod_ Order No_", "Prod_ Order Line",
            "Routing No_", "Operation No_", "Prod_ Order Item No_", "Setup Start", "Setup End", "Run Start", "Run End",
            "Runtime Min_", "Setup Time Min_", "Conf_ Qty_", "Scrap Qty_", "No_of Workers", "Time per Piece", "Scrap Code",
            "Scrap Commets", "Repair Code", mod_de
    from nav.tbl_int_machine_prod_declar_line_load
    on conflict on constraint tbl_int_machine_prod_declar_line_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Prod_ Order No_" = excluded."Prod_ Order No_",
        "Prod_ Order Line" = excluded."Prod_ Order Line",
        "Routing No_" = excluded."Routing No_",
        "Operation No_" = excluded."Operation No_",
        "Prod_ Order Item No_" = excluded."Prod_ Order Item No_",
        "Setup Start" = excluded."Setup Start",
        "Setup End" = excluded."Setup End",
        "Run Start" = excluded."Run Start",
        "Run End" = excluded."Run End",
        "Runtime Min_" = excluded."Runtime Min_",
        "Setup Time Min_" = excluded."Setup Time Min_",
        "Conf_ Qty_" = excluded."Conf_ Qty_",
        "Scrap Qty_" = excluded."Scrap Qty_",
        "No_of Workers" = excluded."No_of Workers",
        "Time per Piece" = excluded."Time per Piece",
        "Scrap Code" = excluded."Scrap Code",
        "Scrap Commets" = excluded."Scrap Commets",
        "Repair Code" = excluded."Repair Code",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_machine_prod_declar_line_load;
end;
$$ language plpgsql;

/* 0017.03 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_machine_prod_declar_indir_time_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_machine_prod_declar_indir_time_merge_load()
as $$
declare
    _rvers bigint;
begin
    _rvers := coalesce((select rowvers from nav.tbl_int_last_rowvers where target_tbl = 'nav.tbl_int_machine_prod_declar'), 0);

    delete from nav.tbl_int_machine_prod_declar_indir_time as a
    using nav.tbl_int_machine_prod_declar as b
    where a."Machine Center No_" = b."Machine Center No_" and a."Date" = b."Date" and a."Work Shift" = b."Work Shift" and b."timestamp" > _rvers;

    insert into nav.tbl_int_machine_prod_declar_indir_time as t ("timestamp", "Machine Center No_", "Date", "Work Shift", "Line No_", "Stop Code", "Observations", "Stop Start",
                                                                "Stop End", "Indirect Time Min_", "No_of Workers", "Item No_ Stacked", mod_de)
    select "timestamp", "Machine Center No_", "Date", "Work Shift", "Line No_", "Stop Code", "Observations", "Stop Start",
            "Stop End", "Indirect Time Min_", "No_of Workers", "Item No_ Stacked", mod_de
    from nav.tbl_int_machine_prod_declar_indir_time_load
    on conflict on constraint tbl_int_machine_prod_declar_indir_time_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Stop Code" = excluded."Stop Code",
        "Observations" = excluded."Observations",
        "Stop Start" = excluded."Stop Start",
        "Stop End" = excluded."Stop End",
        "Indirect Time Min_" = excluded."Indirect Time Min_",
        "No_of Workers" = excluded."No_of Workers",
        "Item No_ Stacked" = excluded."Item No_ Stacked",
        mod_de = excluded.mod_de;

    truncate table nav.tbl_int_machine_prod_declar_indir_time_load;
end;
$$ language plpgsql;

/* 0017.04 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_machine_prod_declar_all_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_machine_prod_declar_all_merge_load()
as $$
declare
    _rvers bigint;
begin
    call nav.prc_machine_prod_declar_line_merge_load();
    call nav.prc_machine_prod_declar_indir_time_merge_load();
    call nav.prc_machine_prod_declar_merge_load(); /* trebuie sa fie ultima */

    _rvers := coalesce((select min(a.timestamp) from nav.tbl_int_machine_prod_declar as a where a."Declaration Status" != 2), 0) - 1; /* status 2 = Posted */

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_machine_prod_declar', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0018.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_vendor_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_vendor_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_vendor as t ("timestamp", "No_", "Name", "Search Name", "Name 2", "Address", "Address 2", "City", "Contact", "Phone No_", "Telex No_",
                                        "Our Account No_", "Territory Code", "Global Dimension 1 Code", "Global Dimension 2 Code", "Budgeted Amount",
                                        "Vendor Posting Group", "Currency Code", "Language Code", "Statistics Group", "Payment Terms Code", "Fin_ Charge Terms Code",
                                        "Purchaser Code", "Shipment Method Code", "Shipping Agent Code", "Invoice Disc_ Code", "Country_Region Code", "Blocked",
                                        "Pay-to Vendor No_", "Priority", "Payment Method Code", "Last Date Modified", "Application Method", "Prices Including VAT",
                                        "Fax No_", "Telex Answer Back", "VAT Registration No_", "Gen_ Bus_ Posting Group", "GLN", "Post Code", "County", "E-Mail",
                                        "Home Page", "No_ Series", "Tax Area Code", "Tax Liable", "VAT Bus_ Posting Group", "Block Payment Tolerance", "IC Partner Code",
                                        "Prepayment _", "Partner Type", "Creditor No_", "Preferred Bank Account Code", "Cash Flow Payment Terms Code", "Primary Contact No_",
                                        "Responsibility Center", "Location Code", "Lead Time Calculation", "Base Calendar Code", "Document Sending Profile",
                                        "Identificator fabrica", "Default Bank Account Code", "Not VAT Registered", "Registration No_", "Commerce Trade No_", "Transaction Type",
                                        "Transaction Specification", "Transport Method", "Currency Transformation Index", "VAT to Pay", "Tip Partener", "Cod Judet D394",
                                        "Organization type", "Data inceput Split TVA", "Data inceput TVA de plata", "Data inceput TVA", "Data sfarsit TVA",
                                        "Data sfarsit TVA de plata", "Inactiv", "Data inactivare", "Data Reactivare", "Data anulare Split TVA", "Registru Plati Defalcate", mod_de)
    select "timestamp", "No_", "Name", "Search Name", "Name 2", "Address", "Address 2", "City", "Contact", "Phone No_", "Telex No_",
            "Our Account No_", "Territory Code", "Global Dimension 1 Code", "Global Dimension 2 Code", "Budgeted Amount",
            "Vendor Posting Group", "Currency Code", "Language Code", "Statistics Group", "Payment Terms Code", "Fin_ Charge Terms Code",
            "Purchaser Code", "Shipment Method Code", "Shipping Agent Code", "Invoice Disc_ Code", "Country_Region Code", "Blocked",
            "Pay-to Vendor No_", "Priority", "Payment Method Code", "Last Date Modified", "Application Method", "Prices Including VAT",
            "Fax No_", "Telex Answer Back", "VAT Registration No_", "Gen_ Bus_ Posting Group", "GLN", "Post Code", "County", "E-Mail",
            "Home Page", "No_ Series", "Tax Area Code", "Tax Liable", "VAT Bus_ Posting Group", "Block Payment Tolerance", "IC Partner Code",
            "Prepayment _", "Partner Type", "Creditor No_", "Preferred Bank Account Code", "Cash Flow Payment Terms Code", "Primary Contact No_",
            "Responsibility Center", "Location Code", "Lead Time Calculation", "Base Calendar Code", "Document Sending Profile",
            "Identificator fabrica", "Default Bank Account Code", "Not VAT Registered", "Registration No_", "Commerce Trade No_", "Transaction Type",
            "Transaction Specification", "Transport Method", "Currency Transformation Index", "VAT to Pay", "Tip Partener", "Cod Judet D394",
            "Organization type", "Data inceput Split TVA", "Data inceput TVA de plata", "Data inceput TVA", "Data sfarsit TVA",
            "Data sfarsit TVA de plata", "Inactiv", "Data inactivare", "Data Reactivare", "Data anulare Split TVA", "Registru Plati Defalcate", mod_de
    from nav.tbl_int_vendor_load
    on conflict on constraint tbl_int_vendor_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Name" = excluded."Name",
        "Search Name" = excluded."Search Name",
        "Name 2" = excluded."Name 2",
        "Address" = excluded."Address",
        "Address 2" = excluded."Address 2",
        "City" = excluded."City",
        "Contact" = excluded."Contact",
        "Phone No_" = excluded."Phone No_",
        "Telex No_" = excluded."Telex No_",
        "Our Account No_" = excluded."Our Account No_",
        "Territory Code" = excluded."Territory Code",
        "Global Dimension 1 Code" = excluded."Global Dimension 1 Code",
        "Global Dimension 2 Code" = excluded."Global Dimension 2 Code",
        "Budgeted Amount" = excluded."Budgeted Amount",
        "Vendor Posting Group" = excluded."Vendor Posting Group",
        "Currency Code" = excluded."Currency Code",
        "Language Code" = excluded."Language Code",
        "Statistics Group" = excluded."Statistics Group",
        "Payment Terms Code" = excluded."Payment Terms Code",
        "Fin_ Charge Terms Code" = excluded."Fin_ Charge Terms Code",
        "Purchaser Code" = excluded."Purchaser Code",
        "Shipment Method Code" = excluded."Shipment Method Code",
        "Shipping Agent Code" = excluded."Shipping Agent Code",
        "Invoice Disc_ Code" = excluded."Invoice Disc_ Code",
        "Country_Region Code" = excluded."Country_Region Code",
        "Blocked" = excluded."Blocked",
        "Pay-to Vendor No_" = excluded."Pay-to Vendor No_",
        "Priority" = excluded."Priority",
        "Payment Method Code" = excluded."Payment Method Code",
        "Last Date Modified" = excluded."Last Date Modified",
        "Application Method" = excluded."Application Method",
        "Prices Including VAT" = excluded."Prices Including VAT",
        "Fax No_" = excluded."Fax No_",
        "Telex Answer Back" = excluded."Telex Answer Back",
        "VAT Registration No_" = excluded."VAT Registration No_",
        "Gen_ Bus_ Posting Group" = excluded."Gen_ Bus_ Posting Group",
        "GLN" = excluded."GLN",
        "Post Code" = excluded."Post Code",
        "County" = excluded."County",
        "E-Mail" = excluded."E-Mail",
        "Home Page" = excluded."Home Page",
        "No_ Series" = excluded."No_ Series",
        "Tax Area Code" = excluded."Tax Area Code",
        "Tax Liable" = excluded."Tax Liable",
        "VAT Bus_ Posting Group" = excluded."VAT Bus_ Posting Group",
        "Block Payment Tolerance" = excluded."Block Payment Tolerance",
        "IC Partner Code" = excluded."IC Partner Code",
        "Prepayment _" = excluded."Prepayment _",
        "Partner Type" = excluded."Partner Type",
        "Creditor No_" = excluded."Creditor No_",
        "Preferred Bank Account Code" = excluded."Preferred Bank Account Code",
        "Cash Flow Payment Terms Code" = excluded."Cash Flow Payment Terms Code",
        "Primary Contact No_" = excluded."Primary Contact No_",
        "Responsibility Center" = excluded."Responsibility Center",
        "Location Code" = excluded."Location Code",
        "Lead Time Calculation" = excluded."Lead Time Calculation",
        "Base Calendar Code" = excluded."Base Calendar Code",
        "Document Sending Profile" = excluded."Document Sending Profile",
        "Identificator fabrica" = excluded."Identificator fabrica",
        "Default Bank Account Code" = excluded."Default Bank Account Code",
        "Not VAT Registered" = excluded."Not VAT Registered",
        "Registration No_" = excluded."Registration No_",
        "Commerce Trade No_" = excluded."Commerce Trade No_",
        "Transaction Type" = excluded."Transaction Type",
        "Transaction Specification" = excluded."Transaction Specification",
        "Transport Method" = excluded."Transport Method",
        "Currency Transformation Index" = excluded."Currency Transformation Index",
        "VAT to Pay" = excluded."VAT to Pay",
        "Tip Partener" = excluded."Tip Partener",
        "Cod Judet D394" = excluded."Cod Judet D394",
        "Organization type" = excluded."Organization type",
        "Data inceput Split TVA" = excluded."Data inceput Split TVA",
        "Data inceput TVA de plata" = excluded."Data inceput TVA de plata",
        "Data inceput TVA" = excluded."Data inceput TVA",
        "Data sfarsit TVA" = excluded."Data sfarsit TVA",
        "Data sfarsit TVA de plata" = excluded."Data sfarsit TVA de plata",
        "Inactiv" = excluded."Inactiv",
        "Data inactivare" = excluded."Data inactivare",
        "Data Reactivare" = excluded."Data Reactivare",
        "Data anulare Split TVA" = excluded."Data anulare Split TVA",
        "Registru Plati Defalcate" = excluded."Registru Plati Defalcate",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_vendor_load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_vendor as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_vendor', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0019.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_gl_account_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_gl_account_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_gl_account as t ("timestamp", "No_", "Name", "Search Name", "Account Type", "Global Dimension 1 Code", "Global Dimension 2 Code",
                                            "Account Category", "Income_Balance", "Debit_Credit", "No_ 2", "Blocked", "Direct Posting", "Reconciliation Account",
                                            "New Page", "No_ of Blank Lines", "Indentation", "Last Date Modified", "Totaling", "Consol_ Translation Method",
                                            "Consol_ Debit Acc_", "Consol_ Credit Acc_", "Gen_ Posting Type", "Gen_ Bus_ Posting Group", "Gen_ Prod_ Posting Group",
                                            "Automatic Ext_ Texts", "Tax Area Code", "Tax Liable", "Tax Group Code", "VAT Bus_ Posting Group", "VAT Prod_ Posting Group",
                                            "Exchange Rate Adjustment", "Default IC Partner G_L Acc_ No", "Omit Default Descr_ in Jnl_", "Account Subcategory Entry No_",
                                            "Cost Type No_", "Default Deferral Template Code", "Analytic_Synthetic1_Synthetic2", "Closing Account", "Check Posting Debit_Credit", mod_de)
    select "timestamp", "No_", "Name", "Search Name", "Account Type", "Global Dimension 1 Code", "Global Dimension 2 Code",
            "Account Category", "Income_Balance", "Debit_Credit", "No_ 2", "Blocked", "Direct Posting", "Reconciliation Account",
            "New Page", "No_ of Blank Lines", "Indentation", "Last Date Modified", "Totaling", "Consol_ Translation Method",
            "Consol_ Debit Acc_", "Consol_ Credit Acc_", "Gen_ Posting Type", "Gen_ Bus_ Posting Group", "Gen_ Prod_ Posting Group",
            "Automatic Ext_ Texts", "Tax Area Code", "Tax Liable", "Tax Group Code", "VAT Bus_ Posting Group", "VAT Prod_ Posting Group",
            "Exchange Rate Adjustment", "Default IC Partner G_L Acc_ No", "Omit Default Descr_ in Jnl_", "Account Subcategory Entry No_",
            "Cost Type No_", "Default Deferral Template Code", "Analytic_Synthetic1_Synthetic2", "Closing Account", "Check Posting Debit_Credit", mod_de
    from nav.tbl_int_gl_account_load
    on conflict on constraint tbl_int_gl_account_pk do
    update set
        "timestamp" = excluded."timestamp",
        "Name" = excluded."Name",
        "Search Name" = excluded."Search Name",
        "Account Type" = excluded."Account Type",
        "Global Dimension 1 Code" = excluded."Global Dimension 1 Code",
        "Global Dimension 2 Code" = excluded."Global Dimension 2 Code",
        "Account Category" = excluded."Account Category",
        "Income_Balance" = excluded."Income_Balance",
        "Debit_Credit" = excluded."Debit_Credit",
        "No_ 2" = excluded."No_ 2",
        "Blocked" = excluded."Blocked",
        "Direct Posting" = excluded."Direct Posting",
        "Reconciliation Account" = excluded."Reconciliation Account",
        "New Page" = excluded."New Page",
        "No_ of Blank Lines" = excluded."No_ of Blank Lines",
        "Indentation" = excluded."Indentation",
        "Last Date Modified" = excluded."Last Date Modified",
        "Totaling" = excluded."Totaling",
        "Consol_ Translation Method" = excluded."Consol_ Translation Method",
        "Consol_ Debit Acc_" = excluded."Consol_ Debit Acc_",
        "Consol_ Credit Acc_" = excluded."Consol_ Credit Acc_",
        "Gen_ Posting Type" = excluded."Gen_ Posting Type",
        "Gen_ Bus_ Posting Group" = excluded."Gen_ Bus_ Posting Group",
        "Gen_ Prod_ Posting Group" = excluded."Gen_ Prod_ Posting Group",
        "Automatic Ext_ Texts" = excluded."Automatic Ext_ Texts",
        "Tax Area Code" = excluded."Tax Area Code",
        "Tax Liable" = excluded."Tax Liable",
        "Tax Group Code" = excluded."Tax Group Code",
        "VAT Bus_ Posting Group" = excluded."VAT Bus_ Posting Group",
        "VAT Prod_ Posting Group" = excluded."VAT Prod_ Posting Group",
        "Exchange Rate Adjustment" = excluded."Exchange Rate Adjustment",
        "Default IC Partner G_L Acc_ No" = excluded."Default IC Partner G_L Acc_ No",
        "Omit Default Descr_ in Jnl_" = excluded."Omit Default Descr_ in Jnl_",
        "Account Subcategory Entry No_" = excluded."Account Subcategory Entry No_",
        "Cost Type No_" = excluded."Cost Type No_",
        "Default Deferral Template Code" = excluded."Default Deferral Template Code",
        "Analytic_Synthetic1_Synthetic2" = excluded."Analytic_Synthetic1_Synthetic2",
        "Closing Account" = excluded."Closing Account",
        "Check Posting Debit_Credit" = excluded."Check Posting Debit_Credit",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_gl_account_load;

    _rvers := coalesce((select max(a.timestamp) from nav.tbl_int_gl_account as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_gl_account', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0020.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_gl_entry_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_gl_entry_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_gl_entry as t ("timestamp", "Entry No_", "G_L Account No_", "Posting Date", "Document Type", "Document No_", "Description",
                                            "Bal_ Account No_", "Amount", "Global Dimension 1 Code", "Global Dimension 2 Code", "User ID", "Source Code",
                                            "System-Created Entry", "Prior-Year Entry", "Job No_", "Quantity", "VAT Amount", "Business Unit Code",
                                            "Journal Batch Name", "Reason Code", "Gen_ Posting Type", "Gen_ Bus_ Posting Group", "Gen_ Prod_ Posting Group",
                                            "Bal_ Account Type", "Transaction No_", "Debit Amount", "Credit Amount", "Document Date", "External Document No_",
                                            "Source Type", "Source No_", "No_ Series", "Tax Area Code", "Tax Liable", "Tax Group Code", "Use Tax", "VAT Bus_ Posting Group",
                                            "VAT Prod_ Posting Group", "Additional-Currency Amount", "Add_-Currency Debit Amount", "Add_-Currency Credit Amount",
                                            "Close Income Statement Dim_ ID", "IC Partner Code", "Reversed", "Reversed by Entry No_", "Reversed Entry No_",
                                            "Dimension Set ID", "Prod_ Order No_", "FA Entry Type", "FA Entry No_", "Custom Invoice No_", "Transfer Self-Invoice",
                                            "Amount (FCY)", "Debit Amount (FCY)", "Credit Amount (FCY)", "Currency Code", "Currency Factor", "Value Entry No_", mod_de)
    select "timestamp", "Entry No_", "G_L Account No_", "Posting Date", "Document Type", "Document No_", "Description",
            "Bal_ Account No_", "Amount", "Global Dimension 1 Code", "Global Dimension 2 Code", "User ID", "Source Code",
            "System-Created Entry", "Prior-Year Entry", "Job No_", "Quantity", "VAT Amount", "Business Unit Code",
            "Journal Batch Name", "Reason Code", "Gen_ Posting Type", "Gen_ Bus_ Posting Group", "Gen_ Prod_ Posting Group",
            "Bal_ Account Type", "Transaction No_", "Debit Amount", "Credit Amount", "Document Date", "External Document No_",
            "Source Type", "Source No_", "No_ Series", "Tax Area Code", "Tax Liable", "Tax Group Code", "Use Tax", "VAT Bus_ Posting Group",
            "VAT Prod_ Posting Group", "Additional-Currency Amount", "Add_-Currency Debit Amount", "Add_-Currency Credit Amount",
            "Close Income Statement Dim_ ID", "IC Partner Code", "Reversed", "Reversed by Entry No_", "Reversed Entry No_",
            "Dimension Set ID", "Prod_ Order No_", "FA Entry Type", "FA Entry No_", "Custom Invoice No_", "Transfer Self-Invoice",
            "Amount (FCY)", "Debit Amount (FCY)", "Credit Amount (FCY)", "Currency Code", "Currency Factor", "Value Entry No_", mod_de
    from nav.tbl_int_gl_entry_load
    on conflict on constraint tbl_int_gl_entry_pk do
    update set
        "timestamp" = excluded."timestamp",
        "G_L Account No_" = excluded."G_L Account No_",
        "Posting Date" = excluded."Posting Date",
        "Document Type" = excluded."Document Type",
        "Document No_" = excluded."Document No_",
        "Description" = excluded."Description",
        "Bal_ Account No_" = excluded."Bal_ Account No_",
        "Amount" = excluded."Amount",
        "Global Dimension 1 Code" = excluded."Global Dimension 1 Code",
        "Global Dimension 2 Code" = excluded."Global Dimension 2 Code",
        "User ID" = excluded."User ID",
        "Source Code" = excluded."Source Code",
        "System-Created Entry" = excluded."System-Created Entry",
        "Prior-Year Entry" = excluded."Prior-Year Entry",
        "Job No_" = excluded."Job No_",
        "Quantity" = excluded."Quantity",
        "VAT Amount" = excluded."VAT Amount",
        "Business Unit Code" = excluded."Business Unit Code",
        "Journal Batch Name" = excluded."Journal Batch Name",
        "Reason Code" = excluded."Reason Code",
        "Gen_ Posting Type" = excluded."Gen_ Posting Type",
        "Gen_ Bus_ Posting Group" = excluded."Gen_ Bus_ Posting Group",
        "Gen_ Prod_ Posting Group" = excluded."Gen_ Prod_ Posting Group",
        "Bal_ Account Type" = excluded."Bal_ Account Type",
        "Transaction No_" = excluded."Transaction No_",
        "Debit Amount" = excluded."Debit Amount",
        "Credit Amount" = excluded."Credit Amount",
        "Document Date" = excluded."Document Date",
        "External Document No_" = excluded."External Document No_",
        "Source Type" = excluded."Source Type",
        "Source No_" = excluded."Source No_",
        "No_ Series" = excluded."No_ Series",
        "Tax Area Code" = excluded."Tax Area Code",
        "Tax Liable" = excluded."Tax Liable",
        "Tax Group Code" = excluded."Tax Group Code",
        "Use Tax" = excluded."Use Tax",
        "VAT Bus_ Posting Group" = excluded."VAT Bus_ Posting Group",
        "VAT Prod_ Posting Group" = excluded."VAT Prod_ Posting Group",
        "Additional-Currency Amount" = excluded."Additional-Currency Amount",
        "Add_-Currency Debit Amount" = excluded."Add_-Currency Debit Amount",
        "Add_-Currency Credit Amount" = excluded."Add_-Currency Credit Amount",
        "Close Income Statement Dim_ ID" = excluded."Close Income Statement Dim_ ID",
        "IC Partner Code" = excluded."IC Partner Code",
        "Reversed" = excluded."Reversed",
        "Reversed by Entry No_" = excluded."Reversed by Entry No_",
        "Reversed Entry No_" = excluded."Reversed Entry No_",
        "Dimension Set ID" = excluded."Dimension Set ID",
        "Prod_ Order No_" = excluded."Prod_ Order No_",
        "FA Entry Type" = excluded."FA Entry Type",
        "FA Entry No_" = excluded."FA Entry No_",
        "Custom Invoice No_" = excluded."Custom Invoice No_",
        "Transfer Self-Invoice" = excluded."Transfer Self-Invoice",
        "Amount (FCY)" = excluded."Amount (FCY)",
        "Debit Amount (FCY)" = excluded."Debit Amount (FCY)",
        "Credit Amount (FCY)" = excluded."Credit Amount (FCY)",
        "Currency Code" = excluded."Currency Code",
        "Currency Factor" = excluded."Currency Factor",
        "Value Entry No_" = excluded."Value Entry No_",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_gl_entry_load;

    _rvers := coalesce((select max(a."Entry No_") from nav.tbl_int_gl_entry as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_gl_entry', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;

/* 0021.01 */
/* ************************************************** */
do $$
begin
    raise notice '************************************';
    raise notice 'creating procedure "prc_gl_item_ledger_relation_merge_load"';
end;
$$ language plpgsql;

create or replace procedure nav.prc_gl_item_ledger_relation_merge_load()
as $$
declare
    _rvers bigint;
begin
    insert into nav.tbl_int_gl_item_ledger_relation as t ("timestamp", "G_L Entry No_", "Value Entry No_", "G_L Register No_", mod_de)
    select "timestamp", "G_L Entry No_", "Value Entry No_", "G_L Register No_", mod_de
    from nav.tbl_int_gl_item_ledger_relation_load
    on conflict on constraint tbl_int_gl_item_ledger_relation_pk do
    update set
        "timestamp" = excluded."timestamp",
        "G_L Register No_" = excluded."G_L Register No_",
        mod_de = excluded.mod_de
    where excluded."timestamp" > t."timestamp";

    truncate table nav.tbl_int_gl_item_ledger_relation_load;

    _rvers := coalesce((select max(a."G_L Entry No_") from nav.tbl_int_gl_item_ledger_relation as a), 0);

    insert into nav.tbl_int_last_rowvers as t (target_tbl, rowvers)
    values ('nav.tbl_int_gl_item_ledger_relation', _rvers)
    on conflict on constraint tbl_int_last_rowvers_pk do
    update set
        rowvers = excluded.rowvers;
end;
$$ language plpgsql;