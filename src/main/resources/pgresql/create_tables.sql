/* code block start */
do $$
declare
    _dbname text := current_database();
begin
    if _dbname != 'any' then
        raise exception 'not in "any" database';
    end if;

/* 0000.01 */
raise notice 'creating schema "nav"';
create schema if not exists nav;
raise notice '************************************';

/* 0001.01 */
raise notice 'creating table "tbl_int_last_rowvers"';
create table if not exists nav.tbl_int_last_rowvers(
    target_tbl text not null,
    rowvers bigint constraint tbl_int_last_rowvers_df_rowvers default 0 not null,
    constraint tbl_int_last_rowvers_pk primary key (target_tbl)
);
raise notice '************************************';

/* 0002.01 */
raise notice 'creating table "tbl_int_prod_bom_header"';
create table if not exists nav.tbl_int_prod_bom_header (
    "timestamp" bigint not null,
    "No_" text not null,
    "Description" text not null,
    "Description 2" text not null,
    "Search Name" text not null,
    "Unit of Measure Code" text not null,
    "Low-Level Code" int not null,
    "Creation Date" timestamp not null,
    "Last Date Modified" timestamp not null,
    "Status" int not null,
    "Version Nos_" text not null,
    "No_ Series" text not null,
    "Type" int not null,
    mod_de timestamp constraint tbl_int_prod_bom_header_df_ts default current_timestamp not null,
    constraint tbl_int_prod_bom_header_pk primary key ("No_")
);
create unique index if not exists tbl_int_prod_bom_header_ix1 on nav.tbl_int_prod_bom_header ("timestamp");
create unique index if not exists tbl_int_prod_bom_header_ix2 on nav.tbl_int_prod_bom_header ("Status", "No_");
raise notice '************************************';

/* 0002.02 */
raise notice 'creating table "tbl_int_prod_bom_header_load"';
create table if not exists nav.tbl_int_prod_bom_header_load (
    "timestamp" bigint not null,
	"No_" text not null,
	"Description" text not null,
	"Description 2" text not null,
	"Search Name" text not null,
	"Unit of Measure Code" text not null,
	"Low-Level Code" int not null,
	"Creation Date" timestamp not null,
	"Last Date Modified" timestamp not null,
	"Status" int not null,
	"Version Nos_" text not null,
	"No_ Series" text not null,
	"Type" int not null,
	mod_de timestamp constraint tbl_int_prod_bom_header_load_df_ts default current_timestamp not null,
    constraint tbl_int_prod_bom_header_load_pk primary key ("No_")
);
raise notice '************************************';

/* 0002.03 */
raise notice 'creating table "tbl_int_prod_bom_header_status"';
create table if not exists nav.tbl_int_prod_bom_header_status(
    "Status" int not null,
    "Status Descr" text not null,
    constraint tbl_int_prod_bom_header_status_pk primary key ("Status")
);
insert into nav.tbl_int_prod_bom_header_status ("Status", "Status Descr")
values (0, 'New'), (1, 'Certified'), (2, 'Under Development'), (3, 'Closed')
on conflict on constraint tbl_int_prod_bom_header_status_pk do nothing;
raise notice '************************************';

/* 0003.01 */
raise notice 'creating table "tbl_int_prod_bom_line"';
create table if not exists nav.tbl_int_prod_bom_line(
    "timestamp" bigint not null,
	"Production BOM No_" text not null,
	"Version Code" text not null,
	"Line No_" int not null,
	"Type" int not null,
	"No_" text not null,
	"Description" text not null,
	"Unit of Measure Code" text not null,
	"Quantity" decimal(38, 20) not null,
	"Position" text not null,
	"Position 2" text not null,
	"Position 3" text not null,
	"Lead-Time Offset" text not null,
	"Routing Link Code" text not null,
	"Scrap _" decimal(38, 20) not null,
	"Variant Code" text not null,
	"Starting Date" timestamp not null,
	"Ending Date" timestamp not null,
	"Length" decimal(38, 20) not null,
	"Width" decimal(38, 20) not null,
	"Weight" decimal(38, 20) not null,
	"Depth" decimal(38, 20) not null,
	"Calculation Formula" int not null,
	"Quantity per" decimal(38, 20) not null,
	"Fitting Note" text not null,
	"Parcel Code" text not null,
	"Randament _" decimal(38, 20) not null,
	"Rebut _" decimal(38, 20) not null,
    mod_de timestamp constraint tbl_int_prod_bom_line_df_ts default current_timestamp not null,
    constraint tbl_int_prod_bom_line_pk primary key ("Production BOM No_", "Version Code", "Line No_")
);
create unique index if not exists tbl_int_prod_bom_line_ix1 on nav.tbl_int_prod_bom_line ("Type" asc, "No_" asc, "Production BOM No_" asc, "Version Code" asc, "Line No_" asc);
raise notice '************************************';

/* 0003.02 */
raise notice 'creating table "tbl_int_prod_bom_line_load"';
create table if not exists nav.tbl_int_prod_bom_line_load(
    "timestamp" bigint not null,
	"Production BOM No_" text not null,
	"Version Code" text not null,
	"Line No_" int not null,
	"Type" int not null,
	"No_" text not null,
	"Description" text not null,
	"Unit of Measure Code" text not null,
	"Quantity" decimal(38, 20) not null,
	"Position" text not null,
	"Position 2" text not null,
	"Position 3" text not null,
	"Lead-Time Offset" text not null,
	"Routing Link Code" text not null,
	"Scrap _" decimal(38, 20) not null,
	"Variant Code" text not null,
	"Starting Date" timestamp not null,
	"Ending Date" timestamp not null,
	"Length" decimal(38, 20) not null,
	"Width" decimal(38, 20) not null,
	"Weight" decimal(38, 20) not null,
	"Depth" decimal(38, 20) not null,
	"Calculation Formula" int not null,
	"Quantity per" decimal(38, 20) not null,
	"Fitting Note" text not null,
	"Parcel Code" text not null,
	"Randament _" decimal(38, 20) not null,
	"Rebut _" decimal(38, 20) not null,
    mod_de timestamp constraint tbl_int_prod_bom_line_load_df_ts default current_timestamp not null,
    constraint tbl_int_prod_bom_line__load_pk primary key ("Production BOM No_", "Version Code", "Line No_")
);
raise notice '************************************';

/* 0003.03 */
raise notice 'creating table "tbl_int_prod_bom_line_type"';
create table if not exists nav.tbl_int_prod_bom_line_type(
    "Type" int not null,
    "Type Descr" text not null,
    constraint tbl_int_prod_bom_line_type_pk primary key ("Type")
);
insert into nav.tbl_int_prod_bom_line_type ("Type", "Type Descr")
values (1, 'Item'), (2, 'Production BOM')
on conflict on constraint tbl_int_prod_bom_line_type_pk do nothing;
raise notice '************************************';

/* 0004.01 */
raise notice 'creating table "tbl_int_prod_bom_vers"';
create table if not exists nav.tbl_int_prod_bom_vers(
    "timestamp" bigint not null,
    "Production BOM No_" text not null,
	"Version Code" text not null,
	"Description" text not null,
	"Starting Date" timestamp not null,
	"Unit of Measure Code" text not null,
	"Last Date Modified" timestamp not null,
	"Status" int not null,
	"No_ Series" text not null,
	"Location Code" text not null,
    mod_de timestamp constraint tbl_int_prod_bom_vers_df_ts default current_timestamp not null,
    constraint tbl_int_prod_bom_vers_pk primary key ("Production BOM No_", "Version Code")
);
create unique index if not exists tbl_int_prod_bom_vers_ix1 on nav.tbl_int_prod_bom_vers ("Production BOM No_", "Starting Date", "Version Code");
raise notice '************************************';

/* 0004.02 */
raise notice 'creating table "tbl_int_prod_bom_vers_load"';
create table if not exists nav.tbl_int_prod_bom_vers_load(
    "timestamp" bigint not null,
    "Production BOM No_" text not null,
	"Version Code" text not null,
	"Description" text not null,
	"Starting Date" timestamp not null,
	"Unit of Measure Code" text not null,
	"Last Date Modified" timestamp not null,
	"Status" int not null,
	"No_ Series" text not null,
	"Location Code" text not null,
    mod_de timestamp constraint tbl_int_prod_bom_vers_load_df_ts default current_timestamp not null,
    constraint tbl_int_prod_bom_vers_load_pk primary key ("Production BOM No_", "Version Code")
);
raise notice '************************************';

/* 0005.01 */
raise notice 'creating table "tbl_int_routing_header"';
create table if not exists nav.tbl_int_routing_header(
    "timestamp" bigint not null,
    "No_" text not null,
	"Description" text not null,
	"Description 2" text not null,
	"Search Description" text not null,
	"Last Date Modified" timestamp not null,
	"Status" int not null,
	"Type" int not null,
	"Version Nos_" text not null,
	"No_ Series" text not null,
     mod_de timestamp constraint tbl_int_routing_header_df_ts default current_timestamp not null,
     constraint tbl_int_routing_header_pk primary key ("No_")
);
create unique index if not exists tbl_int_routing_header_ix1 on nav.tbl_int_routing_header ("timestamp");
create unique index if not exists tbl_int_routing_header_ix2 on nav.tbl_int_routing_header ("Status", "No_");
raise notice '************************************';

/* 0005.02 */
raise notice 'creating table "tbl_int_routing_header_load"';
create table if not exists nav.tbl_int_routing_header_load(
    "timestamp" bigint not null,
    "No_" text not null,
	"Description" text not null,
	"Description 2" text not null,
	"Search Description" text not null,
	"Last Date Modified" timestamp not null,
	"Status" int not null,
	"Type" int not null,
	"Version Nos_" text not null,
	"No_ Series" text not null,
     mod_de timestamp constraint tbl_int_routing_header_load_df_ts default current_timestamp not null,
     constraint tbl_int_routing_header_load_pk primary key ("No_")
);
raise notice '************************************';

/* 0005.03 */
raise notice 'creating table "tbl_int_routing_header_status"';
create table if not exists nav.tbl_int_routing_header_status(
    "Status" int not null,
    "Status Descr" text not null,
    constraint tbl_int_routing_header_status_pk primary key ("Status")
);
insert into nav.tbl_int_routing_header_status ("Status", "Status Descr")
values (0, 'New'), (1, 'Certified'), (2, 'Under Development'), (3, 'Closed')
on conflict on constraint tbl_int_routing_header_status_pk do nothing;
raise notice '************************************';

/* 0005.04 */
raise notice 'creating table "tbl_int_routing_header_type"';
create table if not exists nav.tbl_int_routing_header_type(
    "Type" int not null,
    "Type Descr" text not null,
    constraint tbl_int_routing_header_type_pk primary key ("Type")
);
insert into nav.tbl_int_routing_header_type ("Type", "Type Descr")
values (0, 'Serial'), (1, 'Parallel')
on conflict on constraint tbl_int_routing_header_type_pk do nothing;
raise notice '************************************';

/* 0006.01 */
raise notice 'creating table "tbl_int_routing_line"';
create table if not exists nav.tbl_int_routing_line(
    "timestamp" bigint not null,
    "Routing No_" text not null,
	"Version Code" text not null,
	"Operation No_" text not null,
	"Next Operation No_" text not null,
	"Previous Operation No_" text not null,
	"Type" int not null,
	"No_" text not null,
	"Work Center No_" text not null,
	"Work Center Group Code" text not null,
	"Description" text not null,
	"Setup Time" decimal(38, 20) not null,
	"Run Time" decimal(38, 20) not null,
	"Wait Time" decimal(38, 20) not null,
	"Move Time" decimal(38, 20) not null,
	"Fixed Scrap Quantity" decimal(38, 20) not null,
	"Lot Size" decimal(38, 20) not null,
	"Scrap Factor _" decimal(38, 20) not null,
	"Setup Time Unit of Meas_ Code" text not null,
	"Run Time Unit of Meas_ Code" text not null,
	"Wait Time Unit of Meas_ Code" text not null,
	"Move Time Unit of Meas_ Code" text not null,
	"Minimum Process Time" decimal(38, 20) not null,
	"Maximum Process Time" decimal(38, 20) not null,
	"Concurrent Capacities" decimal(38, 20) not null,
	"Send-Ahead Quantity" decimal(38, 20) not null,
	"Routing Link Code" text not null,
	"Standard Task Code" text not null,
	"Unit Cost per" decimal(38, 20) not null,
	"Recalculate" smallint not null,
	"Sequence No_ (Forward)" int not null,
	"Sequence No_ (Backward)" int not null,
	"Fixed Scrap Qty_ (Accum_)" decimal(38, 20) not null,
	"Scrap Factor _ (Accumulated)" decimal(38, 20) not null,
	"Machine Efficiency (_)" int not null,
	"No_ Of Workers" int not null,
	"Net Setup Time" decimal(38, 20) not null,
	"Net Run Time" decimal(38, 20) not null,
	"Description 2" text not null,
    mod_de timestamp constraint tbl_int_routing_line_df_ts default current_timestamp not null,
    constraint tbl_int_routing_line_pk primary key ("Routing No_", "Version Code", "Operation No_")
);
create unique index if not exists tbl_int_routing_line_ix1 on nav.tbl_int_routing_line ("Routing No_", "Version Code", "Sequence No_ (Forward)", "Operation No_");
create unique index if not exists tbl_int_routing_line_ix2 on nav.tbl_int_routing_line ("Routing No_", "Version Code", "Sequence No_ (Backward)", "Operation No_");
create unique index if not exists tbl_int_routing_line_ix3 on nav.tbl_int_routing_line ("Work Center No_", "Routing No_", "Version Code", "Operation No_");
create unique index if not exists tbl_int_routing_line_ix4 on nav.tbl_int_routing_line ("Type", "No_", "Routing No_", "Version Code", "Operation No_");
create unique index if not exists tbl_int_routing_line_ix5 on nav.tbl_int_routing_line ("Routing Link Code", "Routing No_", "Version Code", "Operation No_");
raise notice '************************************';

/* 0006.02 */
raise notice 'creating table "tbl_int_routing_line_load"';
create table if not exists nav.tbl_int_routing_line_load(
    "timestamp" bigint not null,
    "Routing No_" text not null,
	"Version Code" text not null,
	"Operation No_" text not null,
	"Next Operation No_" text not null,
	"Previous Operation No_" text not null,
	"Type" int not null,
	"No_" text not null,
	"Work Center No_" text not null,
	"Work Center Group Code" text not null,
	"Description" text not null,
	"Setup Time" decimal(38, 20) not null,
	"Run Time" decimal(38, 20) not null,
	"Wait Time" decimal(38, 20) not null,
	"Move Time" decimal(38, 20) not null,
	"Fixed Scrap Quantity" decimal(38, 20) not null,
	"Lot Size" decimal(38, 20) not null,
	"Scrap Factor _" decimal(38, 20) not null,
	"Setup Time Unit of Meas_ Code" text not null,
	"Run Time Unit of Meas_ Code" text not null,
	"Wait Time Unit of Meas_ Code" text not null,
	"Move Time Unit of Meas_ Code" text not null,
	"Minimum Process Time" decimal(38, 20) not null,
	"Maximum Process Time" decimal(38, 20) not null,
	"Concurrent Capacities" decimal(38, 20) not null,
	"Send-Ahead Quantity" decimal(38, 20) not null,
	"Routing Link Code" text not null,
	"Standard Task Code" text not null,
	"Unit Cost per" decimal(38, 20) not null,
	"Recalculate" smallint not null,
	"Sequence No_ (Forward)" int not null,
	"Sequence No_ (Backward)" int not null,
	"Fixed Scrap Qty_ (Accum_)" decimal(38, 20) not null,
	"Scrap Factor _ (Accumulated)" decimal(38, 20) not null,
	"Machine Efficiency (_)" int not null,
	"No_ Of Workers" int not null,
	"Net Setup Time" decimal(38, 20) not null,
	"Net Run Time" decimal(38, 20) not null,
	"Description 2" text not null,
     mod_de timestamp constraint tbl_int_routing_line_load_df_ts default current_timestamp not null,
     constraint tbl_int_routing_line_load_pk primary key ("Routing No_", "Version Code", "Operation No_")
);
raise notice '************************************';

/* 0006.03 */
raise notice 'creating table "tbl_int_routing_line_type"';
create table if not exists nav.tbl_int_routing_line_type(
    "Type" int not null,
    "Type Descr" text not null,
    constraint tbl_int_routing_line_type_pk primary key ("Type")
);
insert into nav.tbl_int_routing_line_type ("Type", "Type Descr")
values (0, 'Work Center'), (1, 'Machine Center')
on conflict on constraint tbl_int_routing_line_type_pk do nothing;
raise notice '************************************';

/* 0007.01 */
raise notice 'creating table "tbl_int_routing_vers"';
create table if not exists nav.tbl_int_routing_vers(
    "timestamp" bigint not null,
    "Routing No_" text not null,
	"Version Code" text not null,
	"Description" text not null,
	"Starting Date" timestamp not null,
	"Status" int not null,
	"Type" int not null,
	"Last Date Modified" timestamp not null,
	"No_ Series" text not null,
	"Location Code" text not null,
    mod_de timestamp constraint tbl_int_routing_vers_df_ts default current_timestamp not null,
    constraint tbl_int_routing_vers_pk primary key ("Routing No_", "Version Code")
);
create unique index if not exists tbl_int_routing_vers_ix1 on nav.tbl_int_routing_vers ("Routing No_", "Starting Date", "Version Code");
raise notice '************************************';

/* 0007.02 */
raise notice 'creating table "tbl_int_routing_vers_load"';
create table if not exists nav.tbl_int_routing_vers_load(
    "timestamp" bigint not null,
    "Routing No_" text not null,
	"Version Code" text not null,
	"Description" text not null,
	"Starting Date" timestamp not null,
	"Status" int not null,
	"Type" int not null,
	"Last Date Modified" timestamp not null,
	"No_ Series" text not null,
	"Location Code" text not null,
    mod_de timestamp constraint tbl_int_routing_vers_load_df_ts default current_timestamp not null,
    constraint tbl_int_routing_vers_load_pk primary key ("Routing No_", "Version Code")
);
raise notice '************************************';

/* 0008.01 */
raise notice 'creating table "tbl_int_item"';
create table if not exists nav.tbl_int_item(
    "timestamp" bigint not null,
    "No_" text not null,
	"No_ 2" text not null,
	"Description" text not null,
	"Search Description" text not null,
	"Description 2" text not null,
	"Base Unit of Measure" text not null,
	"Price Unit Conversion" int not null,
	"Type" int not null,
	"Inventory Posting Group" text not null,
	"Shelf No_" text not null,
	"Item Disc_ Group" text not null,
	"Allow Invoice Disc_" smallint not null,
	"Statistics Group" int not null,
	"Commission Group" int not null,
	"Unit Price" decimal(38, 20) not null,
	"Price_Profit Calculation" int not null,
	"Profit _" decimal(38, 20) not null,
	"Costing Method" int not null,
	"Unit Cost" decimal(38, 20) not null,
	"Standard Cost" decimal(38, 20) not null,
	"Last Direct Cost" decimal(38, 20) not null,
	"Indirect Cost _" decimal(38, 20) not null,
	"Cost is Adjusted" smallint not null,
	"Allow Online Adjustment" smallint not null,
	"Vendor No_" text not null,
	"Vendor Item No_" text not null,
	"Lead Time Calculation" text not null,
	"Reorder Point" decimal(38, 20) not null,
	"Maximum Inventory" decimal(38, 20) not null,
	"Reorder Quantity" decimal(38, 20) not null,
	"Alternative Item No_" text not null,
	"Unit List Price" decimal(38, 20) not null,
	"Duty Due _" decimal(38, 20) not null,
	"Duty Code" text not null,
	"Gross Weight" decimal(38, 20) not null,
	"Net Weight" decimal(38, 20) not null,
	"Units per Parcel" decimal(38, 20) not null,
	"Unit Volume" decimal(38, 20) not null,
	"Durability" text not null,
	"Freight Type" text not null,
	"Tariff No_" text not null,
	"Duty Unit Conversion" decimal(38, 20) not null,
	"Country_Region Purchased Code" text not null,
	"Budget Quantity" decimal(38, 20) not null,
	"Budgeted Amount" decimal(38, 20) not null,
	"Budget Profit" decimal(38, 20) not null,
	"Blocked" smallint not null,
	"Last Date Modified" timestamp not null,
	"Last Time Modified" timestamp not null,
	"Price Includes VAT" smallint not null,
	"VAT Bus_ Posting Gr_ (Price)" text not null,
	"Gen_ Prod_ Posting Group" text not null,
	"Picture" text not null,
	"Country_Region of Origin Code" text not null,
	"Automatic Ext_ Texts" smallint not null,
	"No_ Series" text not null,
	"Tax Group Code" text not null,
	"VAT Prod_ Posting Group" text not null,
	"Reserve" int not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"Stockout Warning" int not null,
	"Prevent Negative Inventory" int not null,
	"Application Wksh_ User ID" text not null,
	"Assembly Policy" int not null,
	"GTIN" text not null,
	"Default Deferral Template Code" text not null,
	"Low-Level Code" int not null,
	"Lot Size" decimal(38, 20) not null,
	"Serial Nos_" text not null,
	"Last Unit Cost Calc_ Date" timestamp not null,
	"Rolled-up Material Cost" decimal(38, 20) not null,
	"Rolled-up Capacity Cost" decimal(38, 20) not null,
	"Scrap _" decimal(38, 20) not null,
	"Inventory Value Zero" smallint not null,
	"Discrete Order Quantity" int not null,
	"Minimum Order Quantity" decimal(38, 20) not null,
	"Maximum Order Quantity" decimal(38, 20) not null,
	"Safety Stock Quantity" decimal(38, 20) not null,
	"Order Multiple" decimal(38, 20) not null,
	"Safety Lead Time" text not null,
	"Flushing Method" int not null,
	"Replenishment System" int not null,
	"Rounding Precision" decimal(38, 20) not null,
	"Sales Unit of Measure" text not null,
	"Purch_ Unit of Measure" text not null,
	"Time Bucket" text not null,
	"Reordering Policy" int not null,
	"Include Inventory" smallint not null,
	"Manufacturing Policy" int not null,
	"Rescheduling Period" text not null,
	"Lot Accumulation Period" text not null,
	"Dampener Period" text not null,
	"Dampener Quantity" decimal(38, 20) not null,
	"Overflow Level" decimal(38, 20) not null,
	"Manufacturer Code" text not null,
	"Item Category Code" text not null,
	"Created From Nonstock Item" smallint not null,
	"Product Group Code" text not null,
	"Service Item Group" text not null,
	"Item Tracking Code" text not null,
	"Lot Nos_" text not null,
	"Expiration Calculation" text not null,
	"Warehouse Class Code" text not null,
	"Special Equipment Code" text not null,
	"Put-away Template Code" text not null,
	"Put-away Unit of Measure Code" text not null,
	"Phys Invt Counting Period Code" text not null,
	"Last Counting Period Update" timestamp not null,
	"Use Cross-Docking" smallint not null,
	"Next Counting Start Date" timestamp not null,
	"Next Counting End Date" timestamp not null,
	"Kit BOM No_" text not null,
	"SAV BOM No_" text not null,
	"KitPurchPriceToBeRecalculated" smallint not null,
	"Plan No_" text not null,
	"Product dimensions mounted" text not null,
	"ABC" text not null,
	"Date (ABC)" timestamp not null,
	"Alerte" int not null,
	"Cod ABCD" text not null,
	"Manufacture" int not null,
	"Range" text not null,
	"Category 1" text not null,
	"Category 2" text not null,
	"Technical Family" text not null,
	"Montat" smallint not null,
	"Is a Prototype" smallint not null,
	"Code Prototype" text not null,
	"MrpDate" timestamp not null,
	"Status" int not null,
	"Life cycle stages" int not null,
	"Packages no_" text not null,
	"Old No_" text not null,
	"Oty_ per pallet" decimal(38, 20) not null,
	"Custom Tax _" decimal(38, 20) not null,
	"Custom Commission _" decimal(38, 20) not null,
	"Full Description" text not null,
	"Routing No_" text not null,
	"Production BOM No_" text not null,
	"Single-Level Material Cost" decimal(38, 20) not null,
	"Single-Level Capacity Cost" decimal(38, 20) not null,
	"Single-Level Subcontrd_ Cost" decimal(38, 20) not null,
	"Single-Level Cap_ Ovhd Cost" decimal(38, 20) not null,
	"Single-Level Mfg_ Ovhd Cost" decimal(38, 20) not null,
	"Overhead Rate" decimal(38, 20) not null,
	"Rolled-up Subcontracted Cost" decimal(38, 20) not null,
	"Rolled-up Mfg_ Ovhd Cost" decimal(38, 20) not null,
	"Rolled-up Cap_ Overhead Cost" decimal(38, 20) not null,
	"Order Tracking Policy" int not null,
	"Critical" smallint not null,
	"Common Item No_" text not null,
	"FSC" text not null,
	"Tip PF" int not null,
	"Consumption Scrap _" decimal(38, 20) not null,
	"Production at Location" text not null,
	"SAV Manufacture" int not null,
    mod_de timestamp constraint tbl_int_item_df_ts default current_timestamp not null,
    constraint tbl_int_item_pk primary key ("No_")
);
create unique index if not exists tbl_int_item_ix1 on nav.tbl_int_item ("Type", "No_");
create unique index if not exists tbl_int_item_ix2 on nav.tbl_int_item ("Inventory Posting Group", "No_");
create unique index if not exists tbl_int_item_ix3 on nav.tbl_int_item ("Production BOM No_", "No_");
create unique index if not exists tbl_int_item_ix4 on nav.tbl_int_item ("Routing No_", "No_");
create unique index if not exists tbl_int_item_ix5 on nav.tbl_int_item ("timestamp");
raise notice '************************************';

/* 0008.02 */
raise notice 'creating table "tbl_int_item_load"';
create table if not exists nav.tbl_int_item_load(
    "timestamp" bigint not null,
    "No_" text not null,
	"No_ 2" text not null,
	"Description" text not null,
	"Search Description" text not null,
	"Description 2" text not null,
	"Base Unit of Measure" text not null,
	"Price Unit Conversion" int not null,
	"Type" int not null,
	"Inventory Posting Group" text not null,
	"Shelf No_" text not null,
	"Item Disc_ Group" text not null,
	"Allow Invoice Disc_" smallint not null,
	"Statistics Group" int not null,
	"Commission Group" int not null,
	"Unit Price" decimal(38, 20) not null,
	"Price_Profit Calculation" int not null,
	"Profit _" decimal(38, 20) not null,
	"Costing Method" int not null,
	"Unit Cost" decimal(38, 20) not null,
	"Standard Cost" decimal(38, 20) not null,
	"Last Direct Cost" decimal(38, 20) not null,
	"Indirect Cost _" decimal(38, 20) not null,
	"Cost is Adjusted" smallint not null,
	"Allow Online Adjustment" smallint not null,
	"Vendor No_" text not null,
	"Vendor Item No_" text not null,
	"Lead Time Calculation" text not null,
	"Reorder Point" decimal(38, 20) not null,
	"Maximum Inventory" decimal(38, 20) not null,
	"Reorder Quantity" decimal(38, 20) not null,
	"Alternative Item No_" text not null,
	"Unit List Price" decimal(38, 20) not null,
	"Duty Due _" decimal(38, 20) not null,
	"Duty Code" text not null,
	"Gross Weight" decimal(38, 20) not null,
	"Net Weight" decimal(38, 20) not null,
	"Units per Parcel" decimal(38, 20) not null,
	"Unit Volume" decimal(38, 20) not null,
	"Durability" text not null,
	"Freight Type" text not null,
	"Tariff No_" text not null,
	"Duty Unit Conversion" decimal(38, 20) not null,
	"Country_Region Purchased Code" text not null,
	"Budget Quantity" decimal(38, 20) not null,
	"Budgeted Amount" decimal(38, 20) not null,
	"Budget Profit" decimal(38, 20) not null,
	"Blocked" smallint not null,
	"Last Date Modified" timestamp not null,
	"Last Time Modified" timestamp not null,
	"Price Includes VAT" smallint not null,
	"VAT Bus_ Posting Gr_ (Price)" text not null,
	"Gen_ Prod_ Posting Group" text not null,
	"Picture" text not null,
	"Country_Region of Origin Code" text not null,
	"Automatic Ext_ Texts" smallint not null,
	"No_ Series" text not null,
	"Tax Group Code" text not null,
	"VAT Prod_ Posting Group" text not null,
	"Reserve" int not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"Stockout Warning" int not null,
	"Prevent Negative Inventory" int not null,
	"Application Wksh_ User ID" text not null,
	"Assembly Policy" int not null,
	"GTIN" text not null,
	"Default Deferral Template Code" text not null,
	"Low-Level Code" int not null,
	"Lot Size" decimal(38, 20) not null,
	"Serial Nos_" text not null,
	"Last Unit Cost Calc_ Date" timestamp not null,
	"Rolled-up Material Cost" decimal(38, 20) not null,
	"Rolled-up Capacity Cost" decimal(38, 20) not null,
	"Scrap _" decimal(38, 20) not null,
	"Inventory Value Zero" smallint not null,
	"Discrete Order Quantity" int not null,
	"Minimum Order Quantity" decimal(38, 20) not null,
	"Maximum Order Quantity" decimal(38, 20) not null,
	"Safety Stock Quantity" decimal(38, 20) not null,
	"Order Multiple" decimal(38, 20) not null,
	"Safety Lead Time" text not null,
	"Flushing Method" int not null,
	"Replenishment System" int not null,
	"Rounding Precision" decimal(38, 20) not null,
	"Sales Unit of Measure" text not null,
	"Purch_ Unit of Measure" text not null,
	"Time Bucket" text not null,
	"Reordering Policy" int not null,
	"Include Inventory" smallint not null,
	"Manufacturing Policy" int not null,
	"Rescheduling Period" text not null,
	"Lot Accumulation Period" text not null,
	"Dampener Period" text not null,
	"Dampener Quantity" decimal(38, 20) not null,
	"Overflow Level" decimal(38, 20) not null,
	"Manufacturer Code" text not null,
	"Item Category Code" text not null,
	"Created From Nonstock Item" smallint not null,
	"Product Group Code" text not null,
	"Service Item Group" text not null,
	"Item Tracking Code" text not null,
	"Lot Nos_" text not null,
	"Expiration Calculation" text not null,
	"Warehouse Class Code" text not null,
	"Special Equipment Code" text not null,
	"Put-away Template Code" text not null,
	"Put-away Unit of Measure Code" text not null,
	"Phys Invt Counting Period Code" text not null,
	"Last Counting Period Update" timestamp not null,
	"Use Cross-Docking" smallint not null,
	"Next Counting Start Date" timestamp not null,
	"Next Counting End Date" timestamp not null,
	"Kit BOM No_" text not null,
	"SAV BOM No_" text not null,
	"KitPurchPriceToBeRecalculated" smallint not null,
	"Plan No_" text not null,
	"Product dimensions mounted" text not null,
	"ABC" text not null,
	"Date (ABC)" timestamp not null,
	"Alerte" int not null,
	"Cod ABCD" text not null,
	"Manufacture" int not null,
	"Range" text not null,
	"Category 1" text not null,
	"Category 2" text not null,
	"Technical Family" text not null,
	"Montat" smallint not null,
	"Is a Prototype" smallint not null,
	"Code Prototype" text not null,
	"MrpDate" timestamp not null,
	"Status" int not null,
	"Life cycle stages" int not null,
	"Packages no_" text not null,
	"Old No_" text not null,
	"Oty_ per pallet" decimal(38, 20) not null,
	"Custom Tax _" decimal(38, 20) not null,
	"Custom Commission _" decimal(38, 20) not null,
	"Full Description" text not null,
	"Routing No_" text not null,
	"Production BOM No_" text not null,
	"Single-Level Material Cost" decimal(38, 20) not null,
	"Single-Level Capacity Cost" decimal(38, 20) not null,
	"Single-Level Subcontrd_ Cost" decimal(38, 20) not null,
	"Single-Level Cap_ Ovhd Cost" decimal(38, 20) not null,
	"Single-Level Mfg_ Ovhd Cost" decimal(38, 20) not null,
	"Overhead Rate" decimal(38, 20) not null,
	"Rolled-up Subcontracted Cost" decimal(38, 20) not null,
	"Rolled-up Mfg_ Ovhd Cost" decimal(38, 20) not null,
	"Rolled-up Cap_ Overhead Cost" decimal(38, 20) not null,
	"Order Tracking Policy" int not null,
	"Critical" smallint not null,
	"Common Item No_" text not null,
	"FSC" text not null,
	"Tip PF" int not null,
	"Consumption Scrap _" decimal(38, 20) not null,
	"Production at Location" text not null,
	"SAV Manufacture" int not null,
    mod_de timestamp constraint tbl_int_item_load_df_ts default current_timestamp not null,
    constraint tbl_int_item_load_pk primary key ("No_")
);
raise notice '************************************';

/* 0008.03 */
raise notice 'creating table "tbl_int_item_manufacture"';
create table if not exists nav.tbl_int_item_manufacture(
    "Manufacture" int not null,
    "Manufacture Descr" text not null,
    constraint tbl_int_item_manufacture_pk primary key ("Manufacture")
);
insert into nav.tbl_int_item_manufacture("Manufacture", "Manufacture Descr")
values (1, 'AIS'), (2, 'AIT'), (3, 'PM'), (4, 'AIB'), (5, 'EXTERN')
on conflict on constraint tbl_int_item_manufacture_pk do nothing;
raise notice '************************************';

/* 0008.04 */
raise notice 'creating table "tbl_int_technical_family_"';
create table if not exists nav.tbl_int_technical_family_(
    "timestamp" bigint not null,
    "Code" text not null,
    "Description" text not null,
    "Description 2" text not null,
	mod_de timestamp constraint tbl_int_technical_family__df_ts default current_timestamp not null,
    constraint tbl_int_technical_family__pk primary key ("Code")
);
create unique index if not exists tbl_int_technical_family__ix1 on nav.tbl_int_technical_family_ ("timestamp");
raise notice '************************************';

/* 0008.05 */
create table if not exists nav.tbl_int_technical_family__load(
    "timestamp" bigint not null,
    "Code" text not null,
    "Description" text not null,
    "Description 2" text not null,
	mod_de timestamp constraint tbl_int_technical_family__load_df_ts default current_timestamp not null,
    constraint tbl_int_technical_family__load_pk primary key ("Code")
);
raise notice '************************************';

/* 0009.01 */
raise notice 'creating table "tbl_int_bom_component"';
create table if not exists nav.tbl_int_bom_component(
    "timestamp" bigint not null,
	"Parent Item No_" text not null,
	"Line No_" int not null,
	"Type" int not null,
	"No_" text not null,
	"Description" text not null,
	"Unit of Measure Code" text not null,
	"Quantity per" decimal(38, 20) not null,
	"Position" text not null,
	"Position 2" text not null,
	"Position 3" text not null,
	"Machine No_" text not null,
	"Lead-Time Offset" text not null,
	"Resource Usage Type" int not null,
	"Variant Code" text not null,
	"Installed in Line No_" int not null,
	"Installed in Item No_" text not null,
    mod_de timestamp constraint tbl_int_bom_component_df_ts default current_timestamp not null,
    constraint tbl_int_bom_component_pk primary key ("Parent Item No_", "Line No_")
);
create unique index if not exists tbl_int_bom_component_ix1 on nav.tbl_int_bom_component ("Type", "No_", "Parent Item No_", "Line No_");
raise notice '************************************';

/* 0009.02 */
raise notice 'creating table "tbl_int_bom_component_load"';
create table if not exists nav.tbl_int_bom_component_load(
    "timestamp" bigint not null,
	"Parent Item No_" text not null,
	"Line No_" int not null,
	"Type" int not null,
	"No_" text not null,
	"Description" text not null,
	"Unit of Measure Code" text not null,
	"Quantity per" decimal(38, 20) not null,
	"Position" text not null,
	"Position 2" text not null,
	"Position 3" text not null,
	"Machine No_" text not null,
	"Lead-Time Offset" text not null,
	"Resource Usage Type" int not null,
	"Variant Code" text not null,
	"Installed in Line No_" int not null,
	"Installed in Item No_" text not null,
    mod_de timestamp constraint tbl_int_bom_component_load_df_ts default current_timestamp not null,
    constraint tbl_int_bom_component_load_pk primary key ("Parent Item No_", "Line No_")
);
raise notice '************************************';

/* 0010.01 */
raise notice 'creating table "tbl_int_production_order"';
create table if not exists nav.tbl_int_production_order(
    "timestamp" bigint not null,
    "Status" int not null,
	"No_" text not null,
	"Description" text not null,
	"Search Description" text not null,
	"Description 2" text not null,
	"Creation Date" timestamp not null,
	"Last Date Modified" timestamp not null,
	"Source Type" int not null,
	"Source No_" text not null,
	"Routing No_" text not null,
	"Inventory Posting Group" text not null,
	"Gen_ Prod_ Posting Group" text not null,
	"Gen_ Bus_ Posting Group" text not null,
	"Starting Time" timestamp not null,
	"Starting Date" timestamp not null,
	"Ending Time" timestamp not null,
	"Ending Date" timestamp not null,
	"Due Date" timestamp not null,
	"Finished Date" timestamp not null,
	"Blocked" smallint not null,
	"Shortcut Dimension 1 Code" text not null,
	"Shortcut Dimension 2 Code" text not null,
	"Location Code" text not null,
	"Bin Code" text not null,
	"Replan Ref_ No_" text not null,
	"Replan Ref_ Status" int not null,
	"Low-Level Code" int not null,
	"Quantity" decimal(38, 20) not null,
	"Unit Cost" decimal(38, 20) not null,
	"Cost Amount" decimal(38, 20) not null,
	"No_ Series" text not null,
	"Planned Order No_" text not null,
	"Firm Planned Order No_" text not null,
	"Simulated Order No_" text not null,
	"Starting Date-Time" timestamp not null,
	"Ending Date-Time" timestamp not null,
	"Dimension Set ID" int not null,
	"Assigned User ID" text not null,
	"Data Primei Planificari" text not null,
	"Linked-to Sales Order" text not null,
	"Linked-to Sales Order Line" int not null,
	"Prod_ Order Finished" smallint not null,
	"Consumption" int not null,
	"Responsability Center" text not null,
	"Responsability Center 2" text not null,
	"All Resp_ Centers" text not null,
	"Observation" text not null,
	"Print" smallint not null,
	"Released Date" timestamp not null,
    mod_de timestamp constraint tbl_int_production_order_df_ts default current_timestamp not null,
    constraint tbl_int_production_order_pk primary key ("Status", "No_")
);
create unique index if not exists tbl_int_production_order_ix1 on nav.tbl_int_production_order ("Source No_", "Status", "No_");
create unique index if not exists tbl_int_production_order_ix2 on nav.tbl_int_production_order ("timestamp");
raise notice '************************************';

/* 0010.02 */
raise notice 'creating table "tbl_int_production_order_load"';
create table if not exists nav.tbl_int_production_order_load(
    "timestamp" bigint not null,
    "Status" int not null,
	"No_" text not null,
	"Description" text not null,
	"Search Description" text not null,
	"Description 2" text not null,
	"Creation Date" timestamp not null,
	"Last Date Modified" timestamp not null,
	"Source Type" int not null,
	"Source No_" text not null,
	"Routing No_" text not null,
	"Inventory Posting Group" text not null,
	"Gen_ Prod_ Posting Group" text not null,
	"Gen_ Bus_ Posting Group" text not null,
	"Starting Time" timestamp not null,
	"Starting Date" timestamp not null,
	"Ending Time" timestamp not null,
	"Ending Date" timestamp not null,
	"Due Date" timestamp not null,
	"Finished Date" timestamp not null,
	"Blocked" smallint not null,
	"Shortcut Dimension 1 Code" text not null,
	"Shortcut Dimension 2 Code" text not null,
	"Location Code" text not null,
	"Bin Code" text not null,
	"Replan Ref_ No_" text not null,
	"Replan Ref_ Status" int not null,
	"Low-Level Code" int not null,
	"Quantity" decimal(38, 20) not null,
	"Unit Cost" decimal(38, 20) not null,
	"Cost Amount" decimal(38, 20) not null,
	"No_ Series" text not null,
	"Planned Order No_" text not null,
	"Firm Planned Order No_" text not null,
	"Simulated Order No_" text not null,
	"Starting Date-Time" timestamp not null,
	"Ending Date-Time" timestamp not null,
	"Dimension Set ID" int not null,
	"Assigned User ID" text not null,
	"Data Primei Planificari" text not null,
	"Linked-to Sales Order" text not null,
	"Linked-to Sales Order Line" int not null,
	"Prod_ Order Finished" smallint not null,
	"Consumption" int not null,
	"Responsability Center" text not null,
	"Responsability Center 2" text not null,
	"All Resp_ Centers" text not null,
	"Observation" text not null,
	"Print" smallint not null,
	"Released Date" timestamp not null,
    mod_de timestamp constraint tbl_int_production_order_load_df_ts default current_timestamp not null,
    constraint tbl_int_production_order_load_pk primary key ("Status", "No_")
);
raise notice '************************************';

/* 0010.03 */
raise notice 'creating table "tbl_int_production_order_status"';
create table if not exists nav.tbl_int_production_order_status(
    "Status" int not null,
    "Description" text not null,
    constraint tbl_int_production_order_status_pk primary key ("Status")
);
insert into nav.tbl_int_production_order_status ("Status", "Description")
values (0, 'Simulated'), (1, 'Planned'), (2, 'Firm Planned'), (3, 'Released'), (4, 'Finished')
on conflict on constraint tbl_int_production_order_status_pk do nothing;
raise notice '************************************';

/* 0011.01 */
raise notice 'creating table "tbl_int_prod_order_line"';
create table if not exists nav.tbl_int_prod_order_line(
    "timestamp" bigint not null,
    "Status" int not null,
	"Prod_ Order No_" text not null,
	"Line No_" int not null,
	"Item No_" text not null,
	"Variant Code" text not null,
	"Description" text not null,
	"Description 2" text not null,
	"Location Code" text not null,
	"Shortcut Dimension 1 Code" text not null,
	"Shortcut Dimension 2 Code" text not null,
	"Bin Code" text not null,
	"Quantity" decimal(38, 20) not null,
	"Finished Quantity" decimal(38, 20) not null,
	"Remaining Quantity" decimal(38, 20) not null,
	"Scrap _" decimal(38, 20) not null,
	"Due Date" timestamp not null,
	"Starting Date" timestamp not null,
	"Starting Time" timestamp not null,
	"Ending Date" timestamp not null,
	"Ending Time" timestamp not null,
	"Planning Level Code" int not null,
	"Priority" int not null,
	"Production BOM No_" text not null,
	"Routing No_" text not null,
	"Inventory Posting Group" text not null,
	"Routing Reference No_" int not null,
	"Unit Cost" decimal(38, 20) not null,
	"Cost Amount" decimal(38, 20) not null,
	"Unit of Measure Code" text not null,
	"Quantity (Base)" decimal(38, 20) not null,
	"Finished Qty_ (Base)" decimal(38, 20) not null,
	"Remaining Qty_ (Base)" decimal(38, 20) not null,
	"Starting Date-Time" timestamp not null,
	"Ending Date-Time" timestamp not null,
	"Dimension Set ID" int not null,
	"Cost Amount (ACY)" decimal(38, 20) not null,
	"Unit Cost (ACY)" decimal(38, 20) not null,
	"Production BOM Version Code" text not null,
	"Routing Version Code" text not null,
	"Routing Type" int not null,
	"Qty_ per Unit of Measure" decimal(38, 20) not null,
	"MPS Order" smallint not null,
	"Planning Flexibility" int not null,
	"Indirect Cost _" decimal(38, 20) not null,
	"Overhead Rate" decimal(38, 20) not null,
	"Responsability Center" text not null,
	"Confim Production date" timestamp not null,
    mod_de timestamp constraint tbl_int_prod_order_line_df_ts default current_timestamp not null,
    constraint tbl_int_prod_order_line_pk primary key ("Status", "Prod_ Order No_", "Line No_")
);
create index if not exists tbl_int_prod_order_line_ix1 on nav.tbl_int_prod_order_line("Prod_ Order No_", "Line No_", "Item No_");
raise notice '************************************';

/* 0011.02 */
raise notice 'creating table "tbl_int_prod_order_line_load"';
create table if not exists nav.tbl_int_prod_order_line_load(
    "timestamp" bigint not null,
    "Status" int not null,
	"Prod_ Order No_" text not null,
	"Line No_" int not null,
	"Item No_" text not null,
	"Variant Code" text not null,
	"Description" text not null,
	"Description 2" text not null,
	"Location Code" text not null,
	"Shortcut Dimension 1 Code" text not null,
	"Shortcut Dimension 2 Code" text not null,
	"Bin Code" text not null,
	"Quantity" decimal(38, 20) not null,
	"Finished Quantity" decimal(38, 20) not null,
	"Remaining Quantity" decimal(38, 20) not null,
	"Scrap _" decimal(38, 20) not null,
	"Due Date" timestamp not null,
	"Starting Date" timestamp not null,
	"Starting Time" timestamp not null,
	"Ending Date" timestamp not null,
	"Ending Time" timestamp not null,
	"Planning Level Code" int not null,
	"Priority" int not null,
	"Production BOM No_" text not null,
	"Routing No_" text not null,
	"Inventory Posting Group" text not null,
	"Routing Reference No_" int not null,
	"Unit Cost" decimal(38, 20) not null,
	"Cost Amount" decimal(38, 20) not null,
	"Unit of Measure Code" text not null,
	"Quantity (Base)" decimal(38, 20) not null,
	"Finished Qty_ (Base)" decimal(38, 20) not null,
	"Remaining Qty_ (Base)" decimal(38, 20) not null,
	"Starting Date-Time" timestamp not null,
	"Ending Date-Time" timestamp not null,
	"Dimension Set ID" int not null,
	"Cost Amount (ACY)" decimal(38, 20) not null,
	"Unit Cost (ACY)" decimal(38, 20) not null,
	"Production BOM Version Code" text not null,
	"Routing Version Code" text not null,
	"Routing Type" int not null,
	"Qty_ per Unit of Measure" decimal(38, 20) not null,
	"MPS Order" smallint not null,
	"Planning Flexibility" int not null,
	"Indirect Cost _" decimal(38, 20) not null,
	"Overhead Rate" decimal(38, 20) not null,
	"Responsability Center" text not null,
	"Confim Production date" timestamp not null,
    mod_de timestamp constraint tbl_int_prod_order_line_load_df_ts default current_timestamp not null,
    constraint tbl_int_prod_order_line_load_pk primary key ("Status", "Prod_ Order No_", "Line No_")
);
raise notice '************************************';

/* 0012.01 */
raise notice 'creating table "tbl_int_prod_order_component"';
create table if not exists nav.tbl_int_prod_order_component(
    "timestamp" bigint not null,
    "Status" int not null,
	"Prod_ Order No_" text not null,
	"Prod_ Order Line No_" int not null,
	"Line No_" int not null,
	"Item No_" text not null,
	"Description" text not null,
	"Unit of Measure Code" text not null,
	"Quantity" decimal(38, 20) not null,
	"Position" text not null,
	"Position 2" text not null,
	"Position 3" text not null,
	"Lead-Time Offset" text not null,
	"Routing Link Code" text not null,
	"Scrap _" decimal(38, 20) not null,
	"Variant Code" text not null,
	"Expected Quantity" decimal(38, 20) not null,
	"Remaining Quantity" decimal(38, 20) not null,
	"Flushing Method" int not null,
	"Location Code" text not null,
	"Shortcut Dimension 1 Code" text not null,
	"Shortcut Dimension 2 Code" text not null,
	"Bin Code" text not null,
	"Supplied-by Line No_" int not null,
	"Planning Level Code" int not null,
	"Item Low-Level Code" int not null,
	"Length" decimal(38, 20) not null,
	"Width" decimal(38, 20) not null,
	"Weight" decimal(38, 20) not null,
	"Depth" decimal(38, 20) not null,
	"Calculation Formula" int not null,
	"Quantity per" decimal(38, 20) not null,
	"Unit Cost" decimal(38, 20) not null,
	"Cost Amount" decimal(38, 20) not null,
	"Due Date" timestamp not null,
	"Due Time" timestamp not null,
	"Qty_ per Unit of Measure" decimal(38, 20) not null,
	"Remaining Qty_ (Base)" decimal(38, 20) not null,
	"Quantity (Base)" decimal(38, 20) not null,
	"Expected Qty_ (Base)" decimal(38, 20) not null,
	"Due Date-Time" timestamp not null,
	"Dimension Set ID" int not null,
	"Original Item No_" text not null,
	"Original Variant Code" text not null,
	"Qty_ Picked" decimal(38, 20) not null,
	"Qty_ Picked (Base)" decimal(38, 20) not null,
	"Completely Picked" smallint not null,
	"Direct Unit Cost" decimal(38, 20) not null,
	"Indirect Cost _" decimal(38, 20) not null,
	"Overhead Rate" decimal(38, 20) not null,
	"Direct Cost Amount" decimal(38, 20) not null,
	"Overhead Amount" decimal(38, 20) not null,
	"Reserv semif" smallint not null,
	"BOM Quantity per" decimal(38, 20) not null,
    mod_de timestamp constraint tbl_int_prod_order_component_df_ts default current_timestamp not null,
    constraint tbl_int_prod_order_component_pk primary key ("Status", "Prod_ Order No_", "Prod_ Order Line No_", "Line No_")
);
create index if not exists tbl_int_prod_order_component_ix1 on nav.tbl_int_prod_order_component("Prod_ Order No_", "Item No_");
raise notice '************************************';

/* 0012.02 */
raise notice 'creating table "tbl_int_prod_order_component_load"';
create table if not exists nav.tbl_int_prod_order_component_load(
    "timestamp" bigint not null,
    "Status" int not null,
	"Prod_ Order No_" text not null,
	"Prod_ Order Line No_" int not null,
	"Line No_" int not null,
	"Item No_" text not null,
	"Description" text not null,
	"Unit of Measure Code" text not null,
	"Quantity" decimal(38, 20) not null,
	"Position" text not null,
	"Position 2" text not null,
	"Position 3" text not null,
	"Lead-Time Offset" text not null,
	"Routing Link Code" text not null,
	"Scrap _" decimal(38, 20) not null,
	"Variant Code" text not null,
	"Expected Quantity" decimal(38, 20) not null,
	"Remaining Quantity" decimal(38, 20) not null,
	"Flushing Method" int not null,
	"Location Code" text not null,
	"Shortcut Dimension 1 Code" text not null,
	"Shortcut Dimension 2 Code" text not null,
	"Bin Code" text not null,
	"Supplied-by Line No_" int not null,
	"Planning Level Code" int not null,
	"Item Low-Level Code" int not null,
	"Length" decimal(38, 20) not null,
	"Width" decimal(38, 20) not null,
	"Weight" decimal(38, 20) not null,
	"Depth" decimal(38, 20) not null,
	"Calculation Formula" int not null,
	"Quantity per" decimal(38, 20) not null,
	"Unit Cost" decimal(38, 20) not null,
	"Cost Amount" decimal(38, 20) not null,
	"Due Date" timestamp not null,
	"Due Time" timestamp not null,
	"Qty_ per Unit of Measure" decimal(38, 20) not null,
	"Remaining Qty_ (Base)" decimal(38, 20) not null,
	"Quantity (Base)" decimal(38, 20) not null,
	"Expected Qty_ (Base)" decimal(38, 20) not null,
	"Due Date-Time" timestamp not null,
	"Dimension Set ID" int not null,
	"Original Item No_" text not null,
	"Original Variant Code" text not null,
	"Qty_ Picked" decimal(38, 20) not null,
	"Qty_ Picked (Base)" decimal(38, 20) not null,
	"Completely Picked" smallint not null,
	"Direct Unit Cost" decimal(38, 20) not null,
	"Indirect Cost _" decimal(38, 20) not null,
	"Overhead Rate" decimal(38, 20) not null,
	"Direct Cost Amount" decimal(38, 20) not null,
	"Overhead Amount" decimal(38, 20) not null,
	"Reserv semif" smallint not null,
	"BOM Quantity per" decimal(38, 20) not null,
    mod_de timestamp constraint tbl_int_prod_order_component_load_df_ts default current_timestamp not null,
    constraint tbl_int_prod_order_component_load_pk primary key ("Status", "Prod_ Order No_", "Prod_ Order Line No_", "Line No_")
);
raise notice '************************************';

/* 0012.03 */
raise notice 'creating table "tbl_int_prod_order_component_flushing_method"';
create table if not exists nav.tbl_int_prod_order_component_flushing_method(
	"Flushing Method" int not null,
	"Description" text not null,
	constraint tbl_int_prod_order_component_flushing_method_pk primary key ("Flushing Method")
);
insert into nav.tbl_int_prod_order_component_flushing_method ("Flushing Method", "Description")
values (0, 'Manual'), (1, 'Forward'), (2, 'Backward'), (3, 'Pick + Forward'), (4, 'Pick + Backward')
on conflict on constraint tbl_int_prod_order_component_flushing_method_pk do nothing;


/* 0013.01 */
raise notice 'creating table "tbl_int_prod_order_routing_line"';
create table if not exists nav.tbl_int_prod_order_routing_line(
    "timestamp" bigint not null,
    "Status" int,
    "Prod_ Order No_" text,
    "Routing Reference No_" int,
    "Routing No_" text,
    "Operation No_" text,
    "Next Operation No_" text,
    "Previous Operation No_" text,
    "Type" int,
    "No_" text,
    "Work Center No_" text,
    "Work Center Group Code" text,
    "Description" text,
    "Setup Time" decimal(38, 20),
    "Run Time" decimal(38, 20),
    "Wait Time" decimal(38, 20),
    "Move Time" decimal(38, 20),
    "Fixed Scrap Quantity" decimal(38, 20),
    "Lot Size" decimal(38, 20),
    "Scrap Factor _" decimal(38, 20),
    "Setup Time Unit of Meas_ Code" text,
    "Run Time Unit of Meas_ Code" text,
    "Wait Time Unit of Meas_ Code" text,
    "Move Time Unit of Meas_ Code" text,
    "Minimum Process Time" decimal(38, 20),
    "Maximum Process Time" decimal(38, 20),
    "Concurrent Capacities" decimal(38, 20),
    "Send-Ahead Quantity" decimal(38, 20),
    "Routing Link Code" text,
    "Standard Task Code" text,
    "Unit Cost per" decimal(38, 20),
    "Recalculate" smallint,
    "Sequence No_ (Forward)" int,
    "Sequence No_ (Backward)" int,
    "Fixed Scrap Qty_ (Accum_)" decimal(38, 20),
    "Scrap Factor _ (Accumulated)" decimal(38, 20),
    "Sequence No_ (Actual)" int,
    "Direct Unit Cost" decimal(38, 20),
    "Indirect Cost _" decimal(38, 20),
    "Overhead Rate" decimal(38, 20),
    "Starting Time" timestamp,
    "Starting Date" timestamp,
    "Ending Time" timestamp,
    "Ending Date" timestamp,
    "Unit Cost Calculation" int,
    "Input Quantity" decimal(38, 20),
    "Critical Path" smallint,
    "Routing Status" int,
    "Flushing Method" int,
    "Expected Operation Cost Amt_" decimal(38, 20),
    "Expected Capacity Need" decimal(38, 20),
    "Expected Capacity Ovhd_ Cost" decimal(38, 20),
    "Starting Date-Time" timestamp,
    "Ending Date-Time" timestamp,
    "Schedule Manually" smallint,
    "Location Code" text,
    "Open Shop Floor Bin Code" text,
    "To-Production Bin Code" text,
    "From-Production Bin Code" text,
    "Seq" int,
    "No_of Workers" int,
    "Estim Machine Time" decimal(38, 20),
    "Estim Workers Time" decimal(38, 20),
    "Description 2" text,
    "DR Run Time" decimal(38, 20),
    "Net Run Time" decimal(38, 20),
    "Machine Efficiency (_)" int,
    "Routing Version Code" text,
    mod_de timestamp constraint tbl_int_prod_order_routing_line_df_ts default current_timestamp not null,
    constraint tbl_int_prod_order_routing_line_pk primary key ("Status", "Prod_ Order No_", "Routing Reference No_", "Routing No_", "Operation No_")
);
raise notice '************************************';

/* 0013.02 */
raise notice 'creating table "tbl_int_prod_order_routing_line_load"';
create table if not exists nav.tbl_int_prod_order_routing_line_load(
    "timestamp" bigint not null,
    "Status" int,
    "Prod_ Order No_" text,
    "Routing Reference No_" int,
    "Routing No_" text,
    "Operation No_" text,
    "Next Operation No_" text,
    "Previous Operation No_" text,
    "Type" int,
    "No_" text,
    "Work Center No_" text,
    "Work Center Group Code" text,
    "Description" text,
    "Setup Time" decimal(38, 20),
    "Run Time" decimal(38, 20),
    "Wait Time" decimal(38, 20),
    "Move Time" decimal(38, 20),
    "Fixed Scrap Quantity" decimal(38, 20),
    "Lot Size" decimal(38, 20),
    "Scrap Factor _" decimal(38, 20),
    "Setup Time Unit of Meas_ Code" text,
    "Run Time Unit of Meas_ Code" text,
    "Wait Time Unit of Meas_ Code" text,
    "Move Time Unit of Meas_ Code" text,
    "Minimum Process Time" decimal(38, 20),
    "Maximum Process Time" decimal(38, 20),
    "Concurrent Capacities" decimal(38, 20),
    "Send-Ahead Quantity" decimal(38, 20),
    "Routing Link Code" text,
    "Standard Task Code" text,
    "Unit Cost per" decimal(38, 20),
    "Recalculate" smallint,
    "Sequence No_ (Forward)" int,
    "Sequence No_ (Backward)" int,
    "Fixed Scrap Qty_ (Accum_)" decimal(38, 20),
    "Scrap Factor _ (Accumulated)" decimal(38, 20),
    "Sequence No_ (Actual)" int,
    "Direct Unit Cost" decimal(38, 20),
    "Indirect Cost _" decimal(38, 20),
    "Overhead Rate" decimal(38, 20),
    "Starting Time" timestamp,
    "Starting Date" timestamp,
    "Ending Time" timestamp,
    "Ending Date" timestamp,
    "Unit Cost Calculation" int,
    "Input Quantity" decimal(38, 20),
    "Critical Path" smallint,
    "Routing Status" int,
    "Flushing Method" int,
    "Expected Operation Cost Amt_" decimal(38, 20),
    "Expected Capacity Need" decimal(38, 20),
    "Expected Capacity Ovhd_ Cost" decimal(38, 20),
    "Starting Date-Time" timestamp,
    "Ending Date-Time" timestamp,
    "Schedule Manually" smallint,
    "Location Code" text,
    "Open Shop Floor Bin Code" text,
    "To-Production Bin Code" text,
    "From-Production Bin Code" text,
    "Seq" int,
    "No_of Workers" int,
    "Estim Machine Time" decimal(38, 20),
    "Estim Workers Time" decimal(38, 20),
    "Description 2" text,
    "DR Run Time" decimal(38, 20),
    "Net Run Time" decimal(38, 20),
    "Machine Efficiency (_)" int,
    "Routing Version Code" text,
     mod_de timestamp constraint tbl_int_prod_order_routing_line_load_df_ts default current_timestamp not null,
     constraint tbl_int_prod_order_routing_line_load_pk primary key ("Status", "Prod_ Order No_", "Routing Reference No_", "Routing No_", "Operation No_")
);
raise notice '************************************';

/* 0014.01 */
raise notice 'creating table "tbl_int_purchase_price"';
create table if not exists nav.tbl_int_purchase_price(
    "timestamp" bigint not null,
    "Item No_" text not null,
	"Vendor No_" text not null,
	"Starting Date" timestamp not null,
	"Currency Code" text not null,
	"Variant Code" text not null,
	"Unit of Measure Code" text not null,
	"Minimum Quantity" decimal(38, 20) not null,
	"Location Code" text not null,
	"Direct Unit Cost" decimal(38, 20) not null,
	"Ending Date" timestamp not null,
    mod_de timestamp constraint tbl_int_purchase_price_df_ts default current_timestamp not null,
    constraint tbl_int_purchase_price_pk primary key ("Item No_", "Vendor No_", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Location Code")
);
create unique index if not exists tbl_int_purchase_price_ix1 on nav.tbl_int_purchase_price ("timestamp");
raise notice '************************************';

/* 0014.02 */
raise notice 'creating table "tbl_int_purchase_price_load"';
create table if not exists nav.tbl_int_purchase_price_load(
    "timestamp" bigint not null,
    "Item No_" text not null,
	"Vendor No_" text not null,
	"Starting Date" timestamp not null,
	"Currency Code" text not null,
	"Variant Code" text not null,
	"Unit of Measure Code" text not null,
	"Minimum Quantity" decimal(38, 20) not null,
	"Location Code" text not null,
	"Direct Unit Cost" decimal(38, 20) not null,
	"Ending Date" timestamp not null,
    mod_de timestamp constraint tbl_int_purchase_price_load_df_ts default current_timestamp not null,
    constraint tbl_int_purchase_price_load_pk primary key ("Item No_", "Vendor No_", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Location Code")
);
raise notice '************************************';

/* 0015.01 */
raise notice 'creating table "tbl_int_sales_price"';
create table if not exists nav.tbl_int_sales_price(
    "timestamp" bigint not null,
    "Item No_" text not null,
	"Sales Type" int not null,
	"Sales Code" text not null,
	"Starting Date" timestamp not null,
	"Currency Code" text not null,
	"Variant Code" text not null,
	"Unit of Measure Code" text not null,
	"Minimum Quantity" decimal(38, 20) not null,
	"Unit Price" decimal(38, 20) not null,
	"Price Includes VAT" smallint not null,
	"Allow Invoice Disc_" smallint not null,
	"VAT Bus_ Posting Gr_ (Price)" text not null,
	"Ending Date" timestamp not null,
	"Allow Line Disc_" smallint not null,
    mod_de timestamp constraint tbl_int_sales_price_df_ts default current_timestamp not null,
    constraint tbl_int_sales_price_pk primary key ("Item No_", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity")
);
create unique index if not exists tbl_int_sales_price_ix1 on nav.tbl_int_sales_price ("timestamp");
raise notice '************************************';

/* 0015.02 */
raise notice 'creating table "tbl_int_sales_price_load"';
create table if not exists nav.tbl_int_sales_price_load(
    "timestamp" bigint not null,
    "Item No_" text not null,
	"Sales Type" int not null,
	"Sales Code" text not null,
	"Starting Date" timestamp not null,
	"Currency Code" text not null,
	"Variant Code" text not null,
	"Unit of Measure Code" text not null,
	"Minimum Quantity" decimal(38, 20) not null,
	"Unit Price" decimal(38, 20) not null,
	"Price Includes VAT" smallint not null,
	"Allow Invoice Disc_" smallint not null,
	"VAT Bus_ Posting Gr_ (Price)" text not null,
	"Ending Date" timestamp not null,
	"Allow Line Disc_" smallint not null,
    mod_de timestamp constraint tbl_int_sales_price_load_df_ts default current_timestamp not null,
    constraint tbl_int_sales_price_load_pk primary key ("Item No_", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity")
);
raise notice '************************************';

/* 0015.03 */
raise notice 'creating table "tbl_int_sales_price_type"';
create table if not exists nav.tbl_int_sales_price_type(
	"Sales Type" int not null,
	"Description" text not null,
	constraint tbl_int_sales_price_type_pk primary key ("Sales Type")
);
insert into nav.tbl_int_sales_price_type("Sales Type", "Description")
values(0, 'Customer'), (1, 'Customer Price Group'), (2, 'All Customers'), (3, 'Campaign')
on conflict on constraint tbl_int_sales_price_type_pk do nothing;

/* 0016.01 */
raise notice 'creating table "tbl_int_item_umas"';
create table if not exists nav.tbl_int_item_umas(
    "timestamp" bigint not null,
    "Item No_" text not null,
	"Code" text not null,
	"Qty_ per Unit of Measure" decimal(38, 20) not null,
	"Length" decimal(38, 20) not null,
	"Width" decimal(38, 20) not null,
	"Height" decimal(38, 20) not null,
	"Cubage" decimal(38, 20) not null,
	"Weight" decimal(38, 20) not null,
	"Packaging Weight" decimal(38, 20) not null,
	"Expanded Polystyren weight" decimal(38, 20) not null,
	"Thinkness" decimal(38, 20) not null,
	"Box weight" decimal(38, 20) not null,
	"Stripe carton weight" decimal(38, 20) not null,
	"Paper weight" decimal(38, 20) not null,
	"Foil weight" decimal(38, 20) not null,
	"PFL_PAL_MDF weight" decimal(38, 20) not null,
    mod_de timestamp constraint tbl_int_item_umas_df_ts default current_timestamp not null,
    constraint tbl_int_item_umas_pk primary key ("Item No_", "Code")
);
create unique index if not exists tbl_int_item_umas_ix1 on nav.tbl_int_item_umas ("timestamp");
raise notice '************************************';

/* 0016.02 */
raise notice 'creating table "tbl_int_item_umas_load"';
create table if not exists nav.tbl_int_item_umas_load(
    "timestamp" bigint not null,
    "Item No_" text not null,
	"Code" text not null,
	"Qty_ per Unit of Measure" decimal(38, 20) not null,
	"Length" decimal(38, 20) not null,
	"Width" decimal(38, 20) not null,
	"Height" decimal(38, 20) not null,
	"Cubage" decimal(38, 20) not null,
	"Weight" decimal(38, 20) not null,
	"Packaging Weight" decimal(38, 20) not null,
	"Expanded Polystyren weight" decimal(38, 20) not null,
	"Thinkness" decimal(38, 20) not null,
	"Box weight" decimal(38, 20) not null,
	"Stripe carton weight" decimal(38, 20) not null,
	"Paper weight" decimal(38, 20) not null,
	"Foil weight" decimal(38, 20) not null,
	"PFL_PAL_MDF weight" decimal(38, 20) not null,
    mod_de timestamp constraint tbl_int_item_umas_load_df_ts default current_timestamp not null,
    constraint tbl_int_item_umas_load_pk primary key ("Item No_", "Code")
);
raise notice '************************************';

/* 0017.01 */
raise notice 'creating table "tbl_int_item_ledger_entry"';
create table if not exists nav.tbl_int_item_ledger_entry(
	"timestamp" bigint not null,
	"Entry No_" int not null,
	"Item No_" text not null,
	"Posting Date" timestamp not null,
	"Entry Type" int not null,
	"Source No_" text not null,
	"Document No_" text not null,
	"Description" text not null,
	"Location Code" text not null,
	"Quantity" decimal(38, 20) not null,
	"Remaining Quantity" decimal(38, 20) not null,
	"Invoiced Quantity" decimal(38, 20) not null,
	"Applies-to Entry" int not null,
	"Open" smallint not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"Positive" smallint not null,
	"Source Type" int not null,
	"Drop Shipment" smallint not null,
	"Transaction Type" text not null,
	"Transport Method" text not null,
	"Country_Region Code" text not null,
	"Entry_Exit Point" text not null,
	"Document Date" timestamp not null,
	"External Document No_" text not null,
	"Area" text not null,
	"Transaction Specification" text not null,
	"No_ Series" text not null,
	"Document Type" int not null,
	"Document Line No_" int not null,
	"Order Type" int not null,
	"Order No_" text not null,
	"Order Line No_" int not null,
	"Dimension Set ID" int not null,
	"Assemble to Order" smallint not null,
	"Job No_" text not null,
	"Job Task No_" text not null,
	"Job Purchase" smallint not null,
	"Variant Code" text not null,
	"Qty_ per Unit of Measure" decimal(38, 20) not null,
	"Unit of Measure Code" text not null,
	"Derived from Blanket Order" smallint not null,
	"Cross-Reference No_" text not null,
	"Originally Ordered No_" text not null,
	"Originally Ordered Var_ Code" text not null,
	"Out-of-Stock Substitution" smallint not null,
	"Item Category Code" text not null,
	"Nonstock" smallint not null,
	"Purchasing Code" text not null,
	"Product Group Code" text not null,
	"Completely Invoiced" smallint not null,
	"Last Invoice Date" timestamp not null,
	"Applied Entry to Adjust" smallint not null,
	"Correction" smallint not null,
	"Shipped Qty_ Not Returned" decimal(38, 20) not null,
	"Prod_ Order Comp_ Line No_" int not null,
	"Serial No_" text not null,
	"Lot No_" text not null,
	"Warranty Date" timestamp not null,
	"Expiration Date" timestamp not null,
	"Item Tracking" int not null,
	"Return Reason Code" text not null,
	"Discount Reason Code" text not null,
	"Order Advertising" smallint not null,
	"EU 3-Party Trade" smallint not null,
	"Tariff No_" text not null,
	"Net Weight" decimal(38, 20) not null,
	"Country_Region of Origin Code" text not null,
	"Intrastat Transaction" smallint not null,
	"Shipment Method Code" text not null,
	"Custom Invoice No_" text not null,
	"No_ Of Workers" int not null,
	"Workers Qty_" decimal(38, 20) not null,
	"Employee No_" text not null,
    mod_de timestamp constraint tbl_int_item_ledger_entry_df1 default current_timestamp not null,
    constraint tbl_int_item_ledger_entry_pk primary key ("Entry No_")
);
create index if not exists tbl_int_item_ledger_entry_ix1 on nav.tbl_int_item_ledger_entry ("Order No_", "Order Line No_", "Entry Type");
create index if not exists tbl_int_item_ledger_entry_ix2 on nav.tbl_int_item_ledger_entry ("Order No_", "Order Line No_", "Prod_ Order Comp_ Line No_");
create index if not exists tbl_int_item_ledger_entry_ix3 on nav.tbl_int_item_ledger_entry ("Item No_", "Posting Date");

raise notice '************************************';

/* 0017.02 */
raise notice 'creating table "tbl_int_item_ledger_entry_load"';
create table if not exists nav.tbl_int_item_ledger_entry_load(
	"timestamp" bigint not null,
	"Entry No_" int not null,
	"Item No_" text not null,
	"Posting Date" timestamp not null,
	"Entry Type" int not null,
	"Source No_" text not null,
	"Document No_" text not null,
	"Description" text not null,
	"Location Code" text not null,
	"Quantity" decimal(38, 20) not null,
	"Remaining Quantity" decimal(38, 20) not null,
	"Invoiced Quantity" decimal(38, 20) not null,
	"Applies-to Entry" int not null,
	"Open" smallint not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"Positive" smallint not null,
	"Source Type" int not null,
	"Drop Shipment" smallint not null,
	"Transaction Type" text not null,
	"Transport Method" text not null,
	"Country_Region Code" text not null,
	"Entry_Exit Point" text not null,
	"Document Date" timestamp not null,
	"External Document No_" text not null,
	"Area" text not null,
	"Transaction Specification" text not null,
	"No_ Series" text not null,
	"Document Type" int not null,
	"Document Line No_" int not null,
	"Order Type" int not null,
	"Order No_" text not null,
	"Order Line No_" int not null,
	"Dimension Set ID" int not null,
	"Assemble to Order" smallint not null,
	"Job No_" text not null,
	"Job Task No_" text not null,
	"Job Purchase" smallint not null,
	"Variant Code" text not null,
	"Qty_ per Unit of Measure" decimal(38, 20) not null,
	"Unit of Measure Code" text not null,
	"Derived from Blanket Order" smallint not null,
	"Cross-Reference No_" text not null,
	"Originally Ordered No_" text not null,
	"Originally Ordered Var_ Code" text not null,
	"Out-of-Stock Substitution" smallint not null,
	"Item Category Code" text not null,
	"Nonstock" smallint not null,
	"Purchasing Code" text not null,
	"Product Group Code" text not null,
	"Completely Invoiced" smallint not null,
	"Last Invoice Date" timestamp not null,
	"Applied Entry to Adjust" smallint not null,
	"Correction" smallint not null,
	"Shipped Qty_ Not Returned" decimal(38, 20) not null,
	"Prod_ Order Comp_ Line No_" int not null,
	"Serial No_" text not null,
	"Lot No_" text not null,
	"Warranty Date" timestamp not null,
	"Expiration Date" timestamp not null,
	"Item Tracking" int not null,
	"Return Reason Code" text not null,
	"Discount Reason Code" text not null,
	"Order Advertising" smallint not null,
	"EU 3-Party Trade" smallint not null,
	"Tariff No_" text not null,
	"Net Weight" decimal(38, 20) not null,
	"Country_Region of Origin Code" text not null,
	"Intrastat Transaction" smallint not null,
	"Shipment Method Code" text not null,
	"Custom Invoice No_" text not null,
	"No_ Of Workers" int not null,
	"Workers Qty_" decimal(38, 20) not null,
	"Employee No_" text not null,
    mod_de timestamp constraint tbl_int_item_ledger_entry_load_df1 default current_timestamp not null,
    constraint tbl_int_item_ledger_entry_load_pk primary key ("Entry No_")
);
raise notice '************************************';

/* 0017.03 */
raise notice 'creating table "tbl_int_item_entry_type"';
create table if not exists nav.tbl_int_item_entry_type(
    "Entry Type" int not null,
    "Description" text not null,
    constraint tbl_int_item_entry_type_pk primary key ("Entry Type")
);
insert into nav.tbl_int_item_entry_type ("Entry Type", "Description")
values (0, 'Purchase'), (1, 'Sale'), (2, 'Positive Adjmt.'), (3, 'Negative Adjmt.'), (4, 'Transfer'), (5, 'Consumption'), (6, 'Output'), (8, 'Assembly Consumption'), (9, 'Assembly Output')
on conflict on constraint tbl_int_item_entry_type_pk do nothing;

raise notice '************************************';

/* 0017.04 */
raise notice 'creating table "tbl_int_item_entry_source_type"';
create table if not exists nav.tbl_int_item_entry_source_type(
    "Source Type" int not null,
    "Description" text not null,
    constraint tbl_int_item_entry_source_type_pk primary key ("Source Type")
);
insert into nav.tbl_int_item_entry_source_type ("Source Type", "Description")
values (1, 'Customer'), (2, 'Vendor'), (3, 'Item')
on conflict on constraint tbl_int_item_entry_source_type_pk do nothing;

raise notice '************************************';

/* 0017.05*/
raise notice 'creating table "tbl_int_item_entry_document_type"';
create table if not exists nav.tbl_int_item_entry_document_type(
    "Document Type" int not null,
    "Description" text not null,
    constraint tbl_int_item_entry_document_type_pk primary key ("Document Type")
);
insert into nav.tbl_int_item_entry_document_type ("Document Type", "Description")
values (1, 'Sales Shipment'), (2, 'Sales Invoice'), (3, 'Sales Return Receipt'), (4, 'Sales Credit Memo'), (5, 'Purchase Receipt'), (6, 'Purchase Invoice'), (7, 'Purchase Return Shipment'),
        (8, 'Purchase Credit Memo'), (9, 'Transfer Shipment'), (10, 'Transfer Receipt'), (11, 'Service Shipment'), (12, 'Service Invoice'), (13, 'Service Credit Memo'), (14, 'Posted Assembly')
on conflict on constraint tbl_int_item_entry_document_type_pk do nothing;

raise notice '************************************';

/* 0017.06 */
raise notice 'creating table "tbl_int_item_entry_order_type"';
create table if not exists nav.tbl_int_item_entry_order_type(
    "Order Type" int not null,
    "Description" text not null,
    constraint tbl_int_item_entry_order_type_pk primary key ("Order Type")
);
insert into nav.tbl_int_item_entry_order_type ("Order Type", "Description")
values (1, 'Production'), (2, 'Transfer'), (3, 'Service'), (4, 'Assembly')
on conflict on constraint tbl_int_item_entry_order_type_pk do nothing;

raise notice '************************************';

/* 0018.01 */
raise notice 'creating table "tbl_int_value_entry"';
create table if not exists nav.tbl_int_value_entry(
    "timestamp" bigint not null,
    "Entry No_" int not null,
    "Item No_" text not null,
    "Posting Date" timestamp not null,
    "Item Ledger Entry Type" int not null,
    "Source No_" text not null,
    "Document No_" text not null,
    "Description" text not null,
    "Location Code" text not null,
    "Inventory Posting Group" text not null,
    "Source Posting Group" text not null,
    "Item Ledger Entry No_" int not null,
    "Valued Quantity" decimal(38, 20) not null,
    "Item Ledger Entry Quantity" decimal(38, 20) not null,
    "Invoiced Quantity" decimal(38, 20) not null,
    "Cost per Unit" decimal(38, 20) not null,
    "Sales Amount (Actual)" decimal(38, 20) not null,
    "Salespers__Purch_ Code" text not null,
    "Discount Amount" decimal(38, 20) not null,
    "User ID" text not null,
    "Source Code" text not null,
    "Applies-to Entry" int not null,
    "Global Dimension 1 Code" text not null,
    "Global Dimension 2 Code" text not null,
    "Source Type" int not null,
    "Cost Amount (Actual)" decimal(38, 20) not null,
    "Cost Posted to G_L" decimal(38, 20) not null,
    "Reason Code" text not null,
    "Drop Shipment" smallint not null,
    "Journal Batch Name" text not null,
    "Gen_ Bus_ Posting Group" text not null,
    "Gen_ Prod_ Posting Group" text not null,
    "Document Date" timestamp not null,
    "External Document No_" text not null,
    "Cost Amount (Actual) (ACY)" decimal(38, 20) not null,
    "Cost Posted to G_L (ACY)" decimal(38, 20) not null,
    "Cost per Unit (ACY)" decimal(38, 20) not null,
    "Document Type" int not null,
    "Document Line No_" int not null,
    "Order Type" int not null,
    "Order No_" text not null,
    "Order Line No_" int not null,
    "Expected Cost" smallint not null,
    "Item Charge No_" text not null,
    "Valued By Average Cost" smallint not null,
    "Partial Revaluation" smallint not null,
    "Inventoriable" smallint not null,
    "Valuation Date" timestamp not null,
    "Entry Type" int not null,
    "Variance Type" int not null,
    "Purchase Amount (Actual)" decimal(38, 20) not null,
    "Purchase Amount (Expected)" decimal(38, 20) not null,
    "Sales Amount (Expected)" decimal(38, 20) not null,
    "Cost Amount (Expected)" decimal(38, 20) not null,
    "Cost Amount (Non-Invtbl_)" decimal(38, 20) not null,
    "Cost Amount (Expected) (ACY)" decimal(38, 20) not null,
    "Cost Amount (Non-Invtbl_)(ACY)" decimal(38, 20) not null,
    "Expected Cost Posted to G_L" decimal(38, 20) not null,
    "Exp_ Cost Posted to G_L (ACY)" decimal(38, 20) not null,
    "Dimension Set ID" int not null,
    "Job No_" text not null,
    "Job Task No_" text not null,
    "Job Ledger Entry No_" int not null,
    "Variant Code" text not null,
    "Adjustment" smallint not null,
    "Average Cost Exception" smallint not null,
    "Capacity Ledger Entry No_" int not null,
    "Type" int not null,
    "No_" text not null,
    "Return Reason Code" text not null,
    "Order Advertising" smallint not null,
    "G_L Correction" smallint not null,
    "Incl_ in Intrastat Amount" smallint not null,
    "Incl_ in Intrastat Stat_ Value" smallint not null,
    "Custom Invoice No_" text not null,
    "Correction Cost" smallint not null,
    mod_de timestamp constraint tbl_int_value_entry_df1 default current_timestamp not null,
    constraint tbl_int_value_entry_pk primary key ("Entry No_")
);
create unique index if not exists tbl_int_value_entry_ix1 on nav.tbl_int_value_entry ("Posting Date", "Document No_", "Entry No_");
create unique index if not exists tbl_int_value_entry_ix2 on nav.tbl_int_value_entry ("Item Ledger Entry No_", "Entry No_");
create index if not exists tbl_int_value_entry_ix3 on nav.tbl_int_value_entry ("Posting Date", "Entry Type", "Item Ledger Entry Type");
create index if not exists tbl_int_value_entry_ix4 on nav.tbl_int_value_entry ("Order No_", "Order Line No_");
create index if not exists tbl_int_value_entry_ix5 on nav.tbl_int_value_entry ("Posting Date", "Inventory Posting Group", "Item No_");

raise notice '************************************';

/* 0018.02 */
raise notice 'creating table "tbl_int_value_entry_load"';
create table if not exists nav.tbl_int_value_entry_load(
    "timestamp" bigint not null,
    "Entry No_" int not null,
    "Item No_" text not null,
    "Posting Date" timestamp not null,
    "Item Ledger Entry Type" int not null,
    "Source No_" text not null,
    "Document No_" text not null,
    "Description" text not null,
    "Location Code" text not null,
    "Inventory Posting Group" text not null,
    "Source Posting Group" text not null,
    "Item Ledger Entry No_" int not null,
    "Valued Quantity" decimal(38, 20) not null,
    "Item Ledger Entry Quantity" decimal(38, 20) not null,
    "Invoiced Quantity" decimal(38, 20) not null,
    "Cost per Unit" decimal(38, 20) not null,
    "Sales Amount (Actual)" decimal(38, 20) not null,
    "Salespers__Purch_ Code" text not null,
    "Discount Amount" decimal(38, 20) not null,
    "User ID" text not null,
    "Source Code" text not null,
    "Applies-to Entry" int not null,
    "Global Dimension 1 Code" text not null,
    "Global Dimension 2 Code" text not null,
    "Source Type" int not null,
    "Cost Amount (Actual)" decimal(38, 20) not null,
    "Cost Posted to G_L" decimal(38, 20) not null,
    "Reason Code" text not null,
    "Drop Shipment" smallint not null,
    "Journal Batch Name" text not null,
    "Gen_ Bus_ Posting Group" text not null,
    "Gen_ Prod_ Posting Group" text not null,
    "Document Date" timestamp not null,
    "External Document No_" text not null,
    "Cost Amount (Actual) (ACY)" decimal(38, 20) not null,
    "Cost Posted to G_L (ACY)" decimal(38, 20) not null,
    "Cost per Unit (ACY)" decimal(38, 20) not null,
    "Document Type" int not null,
    "Document Line No_" int not null,
    "Order Type" int not null,
    "Order No_" text not null,
    "Order Line No_" int not null,
    "Expected Cost" smallint not null,
    "Item Charge No_" text not null,
    "Valued By Average Cost" smallint not null,
    "Partial Revaluation" smallint not null,
    "Inventoriable" smallint not null,
    "Valuation Date" timestamp not null,
    "Entry Type" int not null,
    "Variance Type" int not null,
    "Purchase Amount (Actual)" decimal(38, 20) not null,
    "Purchase Amount (Expected)" decimal(38, 20) not null,
    "Sales Amount (Expected)" decimal(38, 20) not null,
    "Cost Amount (Expected)" decimal(38, 20) not null,
    "Cost Amount (Non-Invtbl_)" decimal(38, 20) not null,
    "Cost Amount (Expected) (ACY)" decimal(38, 20) not null,
    "Cost Amount (Non-Invtbl_)(ACY)" decimal(38, 20) not null,
    "Expected Cost Posted to G_L" decimal(38, 20) not null,
    "Exp_ Cost Posted to G_L (ACY)" decimal(38, 20) not null,
    "Dimension Set ID" int not null,
    "Job No_" text not null,
    "Job Task No_" text not null,
    "Job Ledger Entry No_" int not null,
    "Variant Code" text not null,
    "Adjustment" smallint not null,
    "Average Cost Exception" smallint not null,
    "Capacity Ledger Entry No_" int not null,
    "Type" int not null,
    "No_" text not null,
    "Return Reason Code" text not null,
    "Order Advertising" smallint not null,
    "G_L Correction" smallint not null,
    "Incl_ in Intrastat Amount" smallint not null,
    "Incl_ in Intrastat Stat_ Value" smallint not null,
    "Custom Invoice No_" text not null,
    "Correction Cost" smallint not null,
    mod_de timestamp constraint tbl_int_value_entry_load_df1 default current_timestamp not null,
    constraint tbl_int_value_entry_load_pk primary key ("Entry No_")
);

raise notice '************************************';

/* 0018.03 */
raise notice 'creating table "tbl_int_value_entry_type"';
create table if not exists nav.tbl_int_value_entry_type(
    "Entry Type" int not null,
    "Description" text not null,
    constraint tbl_int_value_entry_type_pk primary key ("Entry Type")
);
insert into nav.tbl_int_value_entry_type ("Entry Type", "Description")
values (0, 'Direct Cost'), (1, 'Revaluation'), (2, 'Rounding'), (3, 'Indirect Cost'), (4, 'Variance')
on conflict on constraint tbl_int_value_entry_type_pk do nothing;

raise notice '************************************';

/* 0018.04 */
raise notice 'creating table "tbl_int_value_entry_variance_type"';
create table if not exists nav.tbl_int_value_entry_variance_type(
    "Variance Type" int not null,
    "Description" text not null,
    constraint tbl_int_value_entry_variance_type_pk primary key ("Variance Type")
);
insert into nav.tbl_int_value_entry_variance_type ("Variance Type", "Description")
values (1, 'Purchase'), (2, 'Material'), (3, 'Capacity'), (4, 'Capacity Overhead'), (5, 'Manufacturing Overhead'), (6, 'Subcontracted')
on conflict on constraint tbl_int_value_entry_variance_type_pk do nothing;

raise notice '************************************';

/* 0018.05 */
raise notice 'creating table "tbl_int_value_entry_capacity_type"';
create table if not exists nav.tbl_int_value_entry_capacity_type(
    "Type" int not null,
    "Description" text not null,
    constraint tbl_int_value_entry_capacity_type_pk primary key ("Type")
);
insert into nav.tbl_int_value_entry_capacity_type ("Type", "Description")
values (0, 'Work Center'), (1, 'Machine Cente'), (3, 'Resource')
on conflict on constraint tbl_int_value_entry_capacity_type_pk do nothing;

raise notice '************************************';

/* 0019.01 */
raise notice 'creating table "tbl_int_customer"';
create table if not exists nav.tbl_int_customer(
    "timestamp" bigint not null,
    "No_" text not null,
    "Name" text not null,
    "Search Name" text not null,
    "Name 2" text not null,
    "Address" text not null,
    "Address 2" text not null,
    "City" text not null,
    "Contact" text not null,
    "Phone No_" text not null,
    "Telex No_" text not null,
    "Document Sending Profile" text not null,
    "Our Account No_" text not null,
    "Territory Code" text not null,
    "Global Dimension 1 Code" text not null,
    "Global Dimension 2 Code" text not null,
    "Chain Name" text not null,
    "Budgeted Amount" decimal(38, 20) not null,
    "Credit Limit (LCY)" decimal(38, 20) not null,
    "Customer Posting Group" text not null,
    "Currency Code" text not null,
    "Customer Price Group" text not null,
    "Language Code" text not null,
    "Statistics Group" int not null,
    "Payment Terms Code" text not null,
    "Fin_ Charge Terms Code" text not null,
    "Salesperson Code" text not null,
    "Shipment Method Code" text not null,
    "Shipping Agent Code" text not null,
    "Place of Export" text not null,
    "Invoice Disc_ Code" text not null,
    "Customer Disc_ Group" text not null,
    "Country_Region Code" text not null,
    "Collection Method" text not null,
    "Amount" decimal(38, 20) not null,
    "Blocked" int not null,
    "Invoice Copies" int not null,
    "Last Statement No_" int not null,
    "Print Statements" smallint not null,
    "Bill-to Customer No_" text not null,
    "Priority" int not null,
    "Payment Method Code" text not null,
    "Last Date Modified" timestamp not null,
    "Application Method" int not null,
    "Prices Including VAT" smallint not null,
    "Location Code" text not null,
    "Fax No_" text not null,
    "Telex Answer Back" text not null,
    "VAT Registration No_" text not null,
    "Combine Shipments" smallint not null,
    "Gen_ Bus_ Posting Group" text not null,
    "GLN" text not null,
    "Post Code" text not null,
    "County" text not null,
    "E-Mail" text not null,
    "Home Page" text not null,
    "Reminder Terms Code" text not null,
    "No_ Series" text not null,
    "Tax Area Code" text not null,
    "Tax Liable" smallint not null,
    "VAT Bus_ Posting Group" text not null,
    "Reserve" int not null,
    "Block Payment Tolerance" smallint not null,
    "IC Partner Code" text not null,
    "Prepayment _" decimal(38, 20) not null,
    "Partner Type" int not null,
    "Image" text not null,
    "Preferred Bank Account Code" text not null,
    "Cash Flow Payment Terms Code" text not null,
    "Primary Contact No_" text not null,
    "Responsibility Center" text not null,
    "Shipping Advice" int not null,
    "Shipping Time" text not null,
    "Shipping Agent Service Code" text not null,
    "Service Zone Code" text not null,
    "Allow Line Disc_" smallint not null,
    "Base Calendar Code" text not null,
    "Copy Sell-to Addr_ to Qte From" int not null,
    "GPS1 latitude" text not null,
    "GPS2 longitude" text not null,
    "Delivery Zone" text not null,
    "Customer Type" text not null,
    "Store Code" text not null,
    "Customer Code PGS" text not null,
    "Email" text not null,
    "Insigna" text not null,
    "Posted Invoice Nos_" text not null,
    "Posted Credit Memo Nos_" text not null,
    "Posted Shipment Nos_" text not null,
    "Posted Return Shipment Nos_" text not null,
    "Ship-to PGS" text not null,
    "Customer no_ 2" text not null,
    "Client de magazin" smallint not null,
    "Cod IRIS" text not null,
    "Phone No_2" text not null,
    "Customer commercial disc_" text not null,
    "Invoice per Sales Order" smallint not null,
    "Data inceput Split TVA" timestamp not null,
    "Data inceput TVA de plata" timestamp not null,
    "Data inceput TVA" timestamp not null,
    "Data sfarsit TVA" timestamp not null,
    "Data sfarsit TVA de plata" timestamp not null,
    "Inactiv" smallint not null,
    "Data inactivare" timestamp not null,
    "Data Reactivare" timestamp not null,
    "Data anulare Split TVA" timestamp not null,
    "VAT to Pay" smallint not null,
    "Registru Plati Defalcate" smallint not null,
    "Lant" text not null,
    "Sublant" text not null,
    "Aderent No_" text not null,
    "Manual Tour Invoice" smallint not null,
    "Franco Limit No_" text not null,
    "Default Bank Account Code" text not null,
    "Customer Contract No_" text not null,
    "Not VAT Registered" smallint not null,
    "Registration No_" text not null,
    "Commerce Trade No_" text not null,
    "Transaction Type" text not null,
    "Transaction Specification" text not null,
    "Transport Method" text not null,
    "Index Invoice Exchage Rate" decimal(38, 20) not null,
    "Organization type" int not null,
    "Tip Partener" int not null,
    "Cod Judet D394" int not null,
    "Budget category" text not null,
    "Network" text not null,
    mod_de timestamp constraint tbl_int_customer_df_ts default current_timestamp not null,
    constraint tbl_int_customer_pk primary key ("No_")
);
create unique index if not exists tbl_int_customer_ix1 on nav.tbl_int_customer ("Customer Posting Group", "No_");
create unique index if not exists tbl_int_customer_ix2 on nav.tbl_int_customer ("timestamp");

raise notice '************************************';

/* 0019.02 */
raise notice 'creating table "tbl_int_customer_load"';
create table if not exists nav.tbl_int_customer_load(
    "timestamp" bigint not null,
    "No_" text not null,
    "Name" text not null,
    "Search Name" text not null,
    "Name 2" text not null,
    "Address" text not null,
    "Address 2" text not null,
    "City" text not null,
    "Contact" text not null,
    "Phone No_" text not null,
    "Telex No_" text not null,
    "Document Sending Profile" text not null,
    "Our Account No_" text not null,
    "Territory Code" text not null,
    "Global Dimension 1 Code" text not null,
    "Global Dimension 2 Code" text not null,
    "Chain Name" text not null,
    "Budgeted Amount" decimal(38, 20) not null,
    "Credit Limit (LCY)" decimal(38, 20) not null,
    "Customer Posting Group" text not null,
    "Currency Code" text not null,
    "Customer Price Group" text not null,
    "Language Code" text not null,
    "Statistics Group" int not null,
    "Payment Terms Code" text not null,
    "Fin_ Charge Terms Code" text not null,
    "Salesperson Code" text not null,
    "Shipment Method Code" text not null,
    "Shipping Agent Code" text not null,
    "Place of Export" text not null,
    "Invoice Disc_ Code" text not null,
    "Customer Disc_ Group" text not null,
    "Country_Region Code" text not null,
    "Collection Method" text not null,
    "Amount" decimal(38, 20) not null,
    "Blocked" int not null,
    "Invoice Copies" int not null,
    "Last Statement No_" int not null,
    "Print Statements" smallint not null,
    "Bill-to Customer No_" text not null,
    "Priority" int not null,
    "Payment Method Code" text not null,
    "Last Date Modified" timestamp not null,
    "Application Method" int not null,
    "Prices Including VAT" smallint not null,
    "Location Code" text not null,
    "Fax No_" text not null,
    "Telex Answer Back" text not null,
    "VAT Registration No_" text not null,
    "Combine Shipments" smallint not null,
    "Gen_ Bus_ Posting Group" text not null,
    "GLN" text not null,
    "Post Code" text not null,
    "County" text not null,
    "E-Mail" text not null,
    "Home Page" text not null,
    "Reminder Terms Code" text not null,
    "No_ Series" text not null,
    "Tax Area Code" text not null,
    "Tax Liable" smallint not null,
    "VAT Bus_ Posting Group" text not null,
    "Reserve" int not null,
    "Block Payment Tolerance" smallint not null,
    "IC Partner Code" text not null,
    "Prepayment _" decimal(38, 20) not null,
    "Partner Type" int not null,
    "Image" text not null,
    "Preferred Bank Account Code" text not null,
    "Cash Flow Payment Terms Code" text not null,
    "Primary Contact No_" text not null,
    "Responsibility Center" text not null,
    "Shipping Advice" int not null,
    "Shipping Time" text not null,
    "Shipping Agent Service Code" text not null,
    "Service Zone Code" text not null,
    "Allow Line Disc_" smallint not null,
    "Base Calendar Code" text not null,
    "Copy Sell-to Addr_ to Qte From" int not null,
    "GPS1 latitude" text not null,
    "GPS2 longitude" text not null,
    "Delivery Zone" text not null,
    "Customer Type" text not null,
    "Store Code" text not null,
    "Customer Code PGS" text not null,
    "Email" text not null,
    "Insigna" text not null,
    "Posted Invoice Nos_" text not null,
    "Posted Credit Memo Nos_" text not null,
    "Posted Shipment Nos_" text not null,
    "Posted Return Shipment Nos_" text not null,
    "Ship-to PGS" text not null,
    "Customer no_ 2" text not null,
    "Client de magazin" smallint not null,
    "Cod IRIS" text not null,
    "Phone No_2" text not null,
    "Customer commercial disc_" text not null,
    "Invoice per Sales Order" smallint not null,
    "Data inceput Split TVA" timestamp not null,
    "Data inceput TVA de plata" timestamp not null,
    "Data inceput TVA" timestamp not null,
    "Data sfarsit TVA" timestamp not null,
    "Data sfarsit TVA de plata" timestamp not null,
    "Inactiv" smallint not null,
    "Data inactivare" timestamp not null,
    "Data Reactivare" timestamp not null,
    "Data anulare Split TVA" timestamp not null,
    "VAT to Pay" smallint not null,
    "Registru Plati Defalcate" smallint not null,
    "Lant" text not null,
    "Sublant" text not null,
    "Aderent No_" text not null,
    "Manual Tour Invoice" smallint not null,
    "Franco Limit No_" text not null,
    "Default Bank Account Code" text not null,
    "Customer Contract No_" text not null,
    "Not VAT Registered" smallint not null,
    "Registration No_" text not null,
    "Commerce Trade No_" text not null,
    "Transaction Type" text not null,
    "Transaction Specification" text not null,
    "Transport Method" text not null,
    "Index Invoice Exchage Rate" decimal(38, 20) not null,
    "Organization type" int not null,
    "Tip Partener" int not null,
    "Cod Judet D394" int not null,
    "Budget category" text not null,
    "Network" text not null,
    mod_de timestamp constraint tbl_int_customer_load_df_ts default current_timestamp not null,
    constraint tbl_int_customer_load_pk primary key ("No_")
);
raise notice '************************************';

/* 0019.03 */
raise notice 'creating table "tbl_int_customer_blocked"';
create table if not exists nav.tbl_int_customer_blocked(
    "Blocked" int not null,
    "Description" text not null,
    constraint tbl_int_customer_blocked_pk primary key ("Blocked")
);
insert into nav.tbl_int_customer_blocked ("Blocked", "Description")
values (1, 'Ship'), (2, 'Invoice'), (3, 'All')
on conflict on constraint tbl_int_customer_blocked_pk do nothing;

raise notice '************************************';

/* 0019.04 */
raise notice 'creating table "tbl_int_customer_application_method"';
create table if not exists nav.tbl_int_customer_application_method(
    "Application Method" int not null,
    "Description" text not null,
    constraint tbl_int_customer_application_method_pk primary key ("Application Method")
);
insert into nav.tbl_int_customer_application_method ("Application Method", "Description")
values (0, 'Manual'), (1, 'Apply to Oldest')
on conflict on constraint tbl_int_customer_application_method_pk do nothing;

raise notice '************************************';

/* 0019.05 */
raise notice 'creating table "tbl_int_customer_reserve"';
create table if not exists nav.tbl_int_customer_reserve(
    "Reserve" int not null,
    "Description" text not null,
    constraint tbl_int_customer_reserve_pk primary key ("Reserve")
);
insert into nav.tbl_int_customer_reserve ("Reserve", "Description")
values (0, 'Never'), (1, 'Optional'), (2, 'Always')
on conflict on constraint tbl_int_customer_reserve_pk do nothing;

raise notice '************************************';

/* 0019.06 */
raise notice 'creating table "tbl_int_customer_partner_type"';
create table if not exists nav.tbl_int_customer_partner_type(
    "Partner Type" int not null,
    "Description" text not null,
    constraint tbl_int_customer_partner_type_pk primary key ("Partner Type")
);
insert into nav.tbl_int_customer_partner_type ("Partner Type", "Description")
values (1, 'Company'), (2, 'Person')
on conflict on constraint tbl_int_customer_partner_type_pk do nothing;

raise notice '************************************';

/* 0020.01 */
raise notice 'creating table "tbl_int_customer_price_group"';
create table if not exists  nav.tbl_int_customer_price_group(
    "timestamp" bigint not null,
    "Code" text not null,
    "Price Includes VAT" smallint not null,
    "Allow Invoice Disc_" smallint not null,
    "VAT Bus_ Posting Gr_ (Price)" text not null,
    "Description" text not null,
    "Allow Line Disc_" smallint not null,
    "Pub Delivery Interval" text not null,
    "RDV Report text" text not null,
    "Std Delivery Interval" text not null,
    "EDI Posted Inv_ Export" smallint not null,
    "DESADV_req" smallint not null,
    "INVOIC_req" smallint not null,
    "ORDRSP_req" smallint not null,
    "Tip rutare" int not null,
    "Invoice FTP link" text not null,
    "User FTP" text not null,
    "Password FTP" text not null,
    "RFA _" decimal(38, 20) not null,
    "Shipment FTP link" text not null,
    "PAR_BY" text not null,
    "Invoice Bank 2" smallint not null,
    mod_de timestamp constraint tbl_int_customer_price_group_df_ts default current_timestamp not null,
    constraint tbl_int_customer_price_group_pk primary key ("Code")
);
create unique index if not exists tbl_int_customer_price_group_ix1 on nav.tbl_int_customer_price_group ("timestamp");
raise notice '************************************';

/* 0020.02 */
raise notice 'creating table "tbl_int_customer_price_group_load"';
create table if not exists  nav.tbl_int_customer_price_group_load(
    "timestamp" bigint not null,
    "Code" text not null,
    "Price Includes VAT" smallint not null,
    "Allow Invoice Disc_" smallint not null,
    "VAT Bus_ Posting Gr_ (Price)" text not null,
    "Description" text not null,
    "Allow Line Disc_" smallint not null,
    "Pub Delivery Interval" text not null,
    "RDV Report text" text not null,
    "Std Delivery Interval" text not null,
    "EDI Posted Inv_ Export" smallint not null,
    "DESADV_req" smallint not null,
    "INVOIC_req" smallint not null,
    "ORDRSP_req" smallint not null,
    "Tip rutare" int not null,
    "Invoice FTP link" text not null,
    "User FTP" text not null,
    "Password FTP" text not null,
    "RFA _" decimal(38, 20) not null,
    "Shipment FTP link" text not null,
    "PAR_BY" text not null,
    "Invoice Bank 2" smallint not null,
    mod_de timestamp constraint tbl_int_customer_price_group_load_df_ts default current_timestamp not null,
    constraint tbl_int_customer_price_group_load_pk primary key ("Code")
);
raise notice '************************************';

/* 0020.03 */
raise notice 'creating table "tbl_int_customer_price_group_tip_rutare"';
create table if not exists nav.tbl_int_customer_price_group_tip_rutare(
    "Tip rutare" int not null,
    "Description" text not null,
    constraint tbl_int_customer_price_group_tip_rutare_pk primary key ("Tip rutare")
);
insert into nav.tbl_int_customer_price_group_tip_rutare ("Tip rutare", "Description")
values (0, 'Automata'), (1, 'Manuala')
on conflict on constraint tbl_int_customer_price_group_tip_rutare_pk do nothing;

raise notice '************************************';

/* 0021.01 */
raise notice 'creating table "tbl_int_warehouse_entry"';
create table if not exists nav.tbl_int_warehouse_entry(
    "timestamp" bigint not null,
    "Entry No_" int not null,
    "Journal Batch Name" text not null,
    "Line No_" int not null,
    "Registering Date" timestamp not null,
    "Location Code" text not null,
    "Zone Code" text not null,
    "Bin Code" text not null,
    "Description" text not null,
    "Item No_" text not null,
    "Quantity" decimal(38, 20) not null,
    "Qty_ (Base)" decimal(38, 20) not null,
    "Source Type" int not null,
    "Source Subtype" int not null,
    "Source No_" text not null,
    "Source Line No_" int not null,
    "Source Subline No_" int not null,
    "Source Document" int not null,
    "Source Code" text not null,
    "Reason Code" text not null,
    "No_ Series" text not null,
    "Bin Type Code" text not null,
    "Cubage" decimal(38, 20) not null,
    "Weight" decimal(38, 20) not null,
    "Journal Template Name" text not null,
    "Whse_ Document No_" text not null,
    "Whse_ Document Type" int not null,
    "Whse_ Document Line No_" int not null,
    "Entry Type" int not null,
    "Reference Document" int not null,
    "Reference No_" text not null,
    "User ID" text not null,
    "Variant Code" text not null,
    "Qty_ per Unit of Measure" decimal(38, 20) not null,
    "Unit of Measure Code" text not null,
    "Serial No_" text not null,
    "Lot No_" text not null,
    "Warranty Date" timestamp not null,
    "Expiration Date" timestamp not null,
    "Phys Invt Counting Period Code" text not null,
    "Phys Invt Counting Period Type" int not null,
    "Dedicated" smallint not null,
    "Pallet No_" text not null,
    mod_de timestamp constraint tbl_int_warehouse_entry_df_ts default current_timestamp not null,
    constraint tbl_int_warehouse_entry_pk primary key ("Entry No_")
);
create unique index if not exists tbl_int_warehouse_entry_ix1 on nav.tbl_int_warehouse_entry ("Reference No_", "Registering Date", "Entry No_");
create index if not exists tbl_int_warehouse_entry_ix2 on nav.tbl_int_warehouse_entry ("Item No_");

raise notice '************************************';

/* 0021.02 */
raise notice 'creating table "tbl_int_warehouse_entry_load"';
create table if not exists nav.tbl_int_warehouse_entry_load(
    "timestamp" bigint not null,
    "Entry No_" int not null,
    "Journal Batch Name" text not null,
    "Line No_" int not null,
    "Registering Date" timestamp not null,
    "Location Code" text not null,
    "Zone Code" text not null,
    "Bin Code" text not null,
    "Description" text not null,
    "Item No_" text not null,
    "Quantity" decimal(38, 20) not null,
    "Qty_ (Base)" decimal(38, 20) not null,
    "Source Type" int not null,
    "Source Subtype" int not null,
    "Source No_" text not null,
    "Source Line No_" int not null,
    "Source Subline No_" int not null,
    "Source Document" int not null,
    "Source Code" text not null,
    "Reason Code" text not null,
    "No_ Series" text not null,
    "Bin Type Code" text not null,
    "Cubage" decimal(38, 20) not null,
    "Weight" decimal(38, 20) not null,
    "Journal Template Name" text not null,
    "Whse_ Document No_" text not null,
    "Whse_ Document Type" int not null,
    "Whse_ Document Line No_" int not null,
    "Entry Type" int not null,
    "Reference Document" int not null,
    "Reference No_" text not null,
    "User ID" text not null,
    "Variant Code" text not null,
    "Qty_ per Unit of Measure" decimal(38, 20) not null,
    "Unit of Measure Code" text not null,
    "Serial No_" text not null,
    "Lot No_" text not null,
    "Warranty Date" timestamp not null,
    "Expiration Date" timestamp not null,
    "Phys Invt Counting Period Code" text not null,
    "Phys Invt Counting Period Type" int not null,
    "Dedicated" smallint not null,
    "Pallet No_" text not null,
    mod_de timestamp constraint tbl_int_warehouse_entry_load_df_ts default current_timestamp not null,
    constraint tbl_int_warehouse_entry_load_pk primary key ("Entry No_")
);
raise notice '************************************';

/* 0021.03 */
raise notice 'creating table "tbl_int_warehouse_entry_source_document"';
create table if not exists nav.tbl_int_warehouse_entry_source_document(
    "Source Document" int not null,
    "Description" text not null,
    constraint tbl_int_warehouse_entry_source_document_pk primary key ("Source Document")
);
insert into nav.tbl_int_warehouse_entry_source_document ("Source Document", "Description")
values (1, 'S. Order'), (2, 'S. Invoice'), (3, 'S. Credit Memo'), (4, 'S. Return Order'), (5, 'P. Order'), (6, 'P. Invoice'), (7, 'P. Credit Memo'), (8, 'P. Return Order'),
        (9, 'Inb. Transfer'), (10, 'Outb. Transfer'), (11, 'Prod. Consumption'), (12, 'Item Jnl.'), (13, 'Phys. Invt. Jnl.'), (14, 'Reclass. Jnl.'), (15, 'Consumption Jnl.'),
        (16, 'Output Jnl'), (17, 'BOM Jnl.'), (18, 'Serv. Order'), (19, 'Job Jnl.'), (20, 'Assembly Consumption'), (21, 'Assembly Order')
on conflict on constraint tbl_int_warehouse_entry_source_document_pk do nothing;

raise notice '************************************';

/* 0021.04 */
raise notice 'creating table "tbl_int_warehouse_entry_whse_document_type"';
create table if not exists nav.tbl_int_warehouse_entry_whse_document_type(
    "Whse_ Document Type" int not null,
    "Description" text not null,
    constraint tbl_int_warehouse_entry_whse_document_type_pk primary key ("Whse_ Document Type")
);
insert into nav.tbl_int_warehouse_entry_whse_document_type ("Whse_ Document Type", "Description")
values (0, 'Whse. Journal'), (1, 'Receipt'), (2, 'Shipment'), (3, 'Internal Put-away'), (4, 'Internal Pick'), (5, 'Production'),
        (6, 'Whse. Phys. Inventory'), (8, 'Assembly')
on conflict on constraint tbl_int_warehouse_entry_whse_document_type_pk do nothing;

raise notice '************************************';

/* 0021.05 */
raise notice 'creating table "tbl_int_warehouse_entry_type"';
create table if not exists nav.tbl_int_warehouse_entry_type(
    "Entry Type" int not null,
    "Description" text not null,
    constraint tbl_int_warehouse_entry_type_pk primary key ("Entry Type")
);
insert into nav.tbl_int_warehouse_entry_type ("Entry Type", "Description")
values (0, 'Negative Adjmt.'), (1, 'Positive Adjmt.'), (2, 'Movement')
on conflict on constraint tbl_int_warehouse_entry_type_pk do nothing;

raise notice '************************************';

/* 0021.06 */
raise notice 'creating table "tbl_int_warehouse_entry_reference_document"';
create table if not exists nav.tbl_int_warehouse_entry_reference_document(
    "Reference Document" int not null,
    "Description" text not null,
    constraint tbl_int_warehouse_entry_reference_document_pk primary key ("Reference Document")
);
insert into nav.tbl_int_warehouse_entry_reference_document ("Reference Document", "Description")
values (1, 'Posted Rcpt'), (2, 'Posted P. Inv.'), (3, 'Posted Rtrn. Rcpt.'), (4, 'Posted P. Cr. Memo'), (5, 'Posted Shipment'), (6, 'Posted S. Inv.'),
        (7, 'Posted Rtrn. Shipment'), (8, 'Posted S. Cr. Memo'), (9, 'Posted T. Receipt'), (10, 'Posted T. Shipment'), (11, 'Item Journal'), (12, 'Prod.'),
        (13, 'Put-away'), (14, 'Pick'), (15, 'Movement'), (16, 'BOM Journal'), (17, 'Job Journal'), (18, 'Assembly')
on conflict on constraint tbl_int_warehouse_entry_reference_document_pk do nothing;

raise notice '************************************';

/* 0021.07 */
raise notice 'creating table "tbl_int_warehouse_entry_phys_invt_counting_period_type"';
create table if not exists nav.tbl_int_warehouse_entry_phys_invt_counting_period_type(
    "Phys Invt Counting Period Type" int not null,
    "Description" text not null,
    constraint tbl_int_warehouse_entry_phys_invt_counting_period_type_pk primary key ("Phys Invt Counting Period Type")
);
insert into nav.tbl_int_warehouse_entry_phys_invt_counting_period_type ("Phys Invt Counting Period Type", "Description")
values (1, 'Item'), (2, 'SKU')
on conflict on constraint tbl_int_warehouse_entry_phys_invt_counting_period_type_pk do nothing;

raise notice '************************************';

/* 0022.01 */
raise notice 'creating table "tbl_int_change_log_entry"';
create table if not exists nav.tbl_int_change_log_entry(
    "timestamp" bigint not null,
	"Entry No_" bigint not null,
	"Date and Time" timestamp not null,
	"Time" timestamp not null,
	"User ID" text not null,
	"Table No_" int not null,
	"Field No_" int not null,
	"Type of Change" int not null,
	"Old Value" text not null,
	"New Value" text not null,
	"Primary Key" text not null,
	"Primary Key Field 1 No_" int not null,
	"Primary Key Field 1 Value" text not null,
	"Primary Key Field 2 No_" int not null,
	"Primary Key Field 2 Value" text not null,
	"Primary Key Field 3 No_" int not null,
	"Primary Key Field 3 Value" text not null,
    mod_de timestamp constraint tbl_int_change_log_entry_df1 default current_timestamp not null,
    constraint tbl_int_change_log_entry_pk primary key ("Entry No_")
);
create index if not exists tbl_int_change_log_entry_ix1 on nav.tbl_int_change_log_entry ("Table No_", "Field No_", "Type of Change");

raise notice '************************************';

/* 0022.02 */
raise notice 'creating table "tbl_int_change_log_entry_load"';
create table if not exists nav.tbl_int_change_log_entry_load(
    "timestamp" bigint not null,
	"Entry No_" bigint not null,
	"Date and Time" timestamp not null,
	"Time" timestamp not null,
	"User ID" text not null,
	"Table No_" int not null,
	"Field No_" int not null,
	"Type of Change" int not null,
	"Old Value" text not null,
	"New Value" text not null,
	"Primary Key" text not null,
	"Primary Key Field 1 No_" int not null,
	"Primary Key Field 1 Value" text not null,
	"Primary Key Field 2 No_" int not null,
	"Primary Key Field 2 Value" text not null,
	"Primary Key Field 3 No_" int not null,
	"Primary Key Field 3 Value" text not null,
    mod_de timestamp constraint tbl_int_change_log_entry_load_df1 default current_timestamp not null,
    constraint tbl_int_change_log_entry_load_pk primary key ("Entry No_")
);
raise notice '************************************';

/* 0022.03 */
raise notice 'creating table "tbl_int_change_log_change_type"';
create table if not exists nav.tbl_int_change_log_change_type(
    "Type of Change" int not null,
    "Description" text not null,
    constraint tbl_int_change_log_change_type_pk primary key ("Type of Change")
);
insert into nav.tbl_int_change_log_change_type ("Type of Change", "Description")
values (0, 'Insertion'), (1, 'Modification'), (2, 'Deletion')
on conflict on constraint tbl_int_change_log_change_type_pk do nothing;

raise notice '************************************';

/* 0023.01 */
raise notice 'creating table "tbl_int_capacity_ledger_entry"';
create table if not exists nav.tbl_int_capacity_ledger_entry(
    "timestamp" bigint not null,
    "Entry No_" int not null,
    "No_" text not null,
    "Posting Date" timestamp not null,
    "Type" int not null,
    "Document No_" text not null,
    "Description" text not null,
    "Operation No_" text not null,
    "Work Center No_" text not null,
    "Quantity" decimal(38, 20) not null,
    "Setup Time" decimal(38, 20) not null,
    "Run Time" decimal(38, 20) not null,
    "Stop Time" decimal(38, 20) not null,
    "Invoiced Quantity" decimal(38, 20) not null,
    "Output Quantity" decimal(38, 20) not null,
    "Scrap Quantity" decimal(38, 20) not null,
    "Concurrent Capacity" decimal(38, 20) not null,
    "Cap_ Unit of Measure Code" text not null,
    "Qty_ per Cap_ Unit of Measure" decimal(38, 20) not null,
    "Global Dimension 1 Code" text not null,
    "Global Dimension 2 Code" text not null,
    "Last Output Line" smallint not null,
    "Completely Invoiced" smallint not null,
    "Starting Time" timestamp not null,
    "Ending Time" timestamp not null,
    "Routing No_" text not null,
    "Routing Reference No_" int not null,
    "Item No_" text not null,
    "Variant Code" text not null,
    "Unit of Measure Code" text not null,
    "Qty_ per Unit of Measure" decimal(38, 20) not null,
    "Document Date" timestamp not null,
    "External Document No_" text not null,
    "Stop Code" text not null,
    "Scrap Code" text not null,
    "Work Center Group Code" text not null,
    "Work Shift Code" text not null,
    "Subcontracting" smallint not null,
    "Order Type" int not null,
    "Order No_" text not null,
    "Order Line No_" int not null,
    "Dimension Set ID" int not null,
    "No_ Of Workers" int not null,
    "Workers Qty_" decimal(38, 20) not null,
    "Employee No_" text not null,
    mod_de timestamp constraint tbl_int_capacity_ledger_entry_df_ts default current_timestamp not null,
    constraint tbl_int_capacity_ledger_entry_pk primary key ("Entry No_")
);
create index if not exists tbl_int_capacity_ledger_entry_ix1 on nav.tbl_int_capacity_ledger_entry ("Order No_", "Order Line No_", "Operation No_");

raise notice '************************************';

/* 0023.02 */
raise notice 'creating table "tbl_int_capacity_ledger_entry_load"';
create table if not exists nav.tbl_int_capacity_ledger_entry_load(
    "timestamp" bigint not null,
    "Entry No_" int not null,
    "No_" text not null,
    "Posting Date" timestamp not null,
    "Type" int not null,
    "Document No_" text not null,
    "Description" text not null,
    "Operation No_" text not null,
    "Work Center No_" text not null,
    "Quantity" decimal(38, 20) not null,
    "Setup Time" decimal(38, 20) not null,
    "Run Time" decimal(38, 20) not null,
    "Stop Time" decimal(38, 20) not null,
    "Invoiced Quantity" decimal(38, 20) not null,
    "Output Quantity" decimal(38, 20) not null,
    "Scrap Quantity" decimal(38, 20) not null,
    "Concurrent Capacity" decimal(38, 20) not null,
    "Cap_ Unit of Measure Code" text not null,
    "Qty_ per Cap_ Unit of Measure" decimal(38, 20) not null,
    "Global Dimension 1 Code" text not null,
    "Global Dimension 2 Code" text not null,
    "Last Output Line" smallint not null,
    "Completely Invoiced" smallint not null,
    "Starting Time" timestamp not null,
    "Ending Time" timestamp not null,
    "Routing No_" text not null,
    "Routing Reference No_" int not null,
    "Item No_" text not null,
    "Variant Code" text not null,
    "Unit of Measure Code" text not null,
    "Qty_ per Unit of Measure" decimal(38, 20) not null,
    "Document Date" timestamp not null,
    "External Document No_" text not null,
    "Stop Code" text not null,
    "Scrap Code" text not null,
    "Work Center Group Code" text not null,
    "Work Shift Code" text not null,
    "Subcontracting" smallint not null,
    "Order Type" int not null,
    "Order No_" text not null,
    "Order Line No_" int not null,
    "Dimension Set ID" int not null,
    "No_ Of Workers" int not null,
    "Workers Qty_" decimal(38, 20) not null,
    "Employee No_" text not null,
    mod_de timestamp constraint tbl_int_capacity_ledger_entry_load_df_ts default current_timestamp not null,
    constraint tbl_int_capacity_ledger_entry_load_pk primary key ("Entry No_")
);
raise notice '************************************';

/* 0023.03 */
raise notice 'creating table "tbl_int_capacity_ledger_entry_type"';
create table if not exists nav.tbl_int_capacity_ledger_entry_type(
    "Type" int not null,
    "Description" text not null,
    constraint tbl_int_capacity_ledger_entry_type_pk primary key ("Type")
);
insert into nav.tbl_int_capacity_ledger_entry_type ("Type", "Description")
values (0, 'Work Center'), (1, 'MAchine Center'), (3, 'Resource')
on conflict on constraint tbl_int_capacity_ledger_entry_type_pk do nothing;

raise notice '************************************';

/* 0023.04 */
raise notice 'creating table "tbl_int_capacity_ledger_entry_order_type"';
create table if not exists nav.tbl_int_capacity_ledger_entry_order_type(
    "Order Type" int not null,
    "Description" text not null,
    constraint tbl_int_capacity_ledger_entry_order_type_pk primary key ("Order Type")
);
insert into nav.tbl_int_capacity_ledger_entry_order_type ("Order Type", "Description")
values (1, 'Production'), (2, 'Transfer'), (3, 'Service'), (4, 'Assembly')
on conflict on constraint tbl_int_capacity_ledger_entry_order_type_pk do nothing;

raise notice '************************************';

/* 0024.01 */
raise notice 'creating table "tbl_int_machine_prod_declar"';
create table if not exists nav.tbl_int_machine_prod_declar(
    "timestamp" bigint not null,
    "Machine Center No_" text not null,
    "Date" timestamp not null,
    "Work Shift" int not null,
    "Declaration Status" int not null,
    "Responsibility Center" text not null,
    "Location Code" text not null,
    "Created By" text not null,
    "Validated By" text not null,
    "Employee No_" text not null,
    mod_de timestamp constraint tbl_int_machine_prod_declar_df_ts default current_timestamp not null,
    constraint tbl_int_machine_prod_declar_pk primary key ("Machine Center No_", "Date", "Work Shift")
);
create unique index if not exists tbl_int_machine_prod_declar_ix1 on nav.tbl_int_machine_prod_declar ("timestamp");
raise notice '************************************';

/* 0024.02 */
raise notice 'creating table "tbl_int_machine_prod_declar_load"';
create table if not exists nav.tbl_int_machine_prod_declar_load(
    "timestamp" bigint not null,
    "Machine Center No_" text not null,
    "Date" timestamp not null,
    "Work Shift" int not null,
    "Declaration Status" int not null,
    "Responsibility Center" text not null,
    "Location Code" text not null,
    "Created By" text not null,
    "Validated By" text not null,
    "Employee No_" text not null,
    mod_de timestamp constraint tbl_int_machine_prod_declar_load_df_ts default current_timestamp not null,
    constraint tbl_int_machine_prod_declar_load_pk primary key ("Machine Center No_", "Date", "Work Shift")
);
raise notice '************************************';

/* 0024.03 */
raise notice 'creating table "tbl_int_machine_prod_declar_status"';
create table if not exists nav.tbl_int_machine_prod_declar_status(
    "Declaration Status" int not null,
    "Description" text not null,
    constraint tbl_int_machine_prod_declar_status_pk primary key ("Declaration Status")
);
insert into nav.tbl_int_machine_prod_declar_status ("Declaration Status", "Description")
values (0, 'Open'), (1, 'Validated'), (2, 'Posted')
on conflict on constraint tbl_int_machine_prod_declar_status_pk do nothing;

raise notice '************************************';

/* 0025.01 */
raise notice 'creating table "tbl_int_machine_prod_declar_line"';
create table if not exists nav.tbl_int_machine_prod_declar_line(
    "timestamp" bigint not null,
    "Machine Center No_" text not null,
    "Date" timestamp not null,
    "Work Shift" int not null,
    "Line No_" int not null,
    "Prod_ Order No_" text not null,
    "Prod_ Order Line" int not null,
    "Routing No_" text not null,
    "Operation No_" text not null,
    "Prod_ Order Item No_" text not null,
    "Setup Start" timestamp not null,
    "Setup End" timestamp not null,
    "Run Start" timestamp not null,
    "Run End" timestamp not null,
    "Runtime Min_" decimal(38, 20) not null,
    "Setup Time Min_" decimal(38, 20) not null,
    "Conf_ Qty_" decimal(38, 20) not null,
    "Scrap Qty_" decimal(38, 20) not null,
    "No_of Workers" int not null,
    "Time per Piece" decimal(38, 20) not null,
    "Scrap Code" text not null,
    "Scrap Commets" text not null,
    "Repair Code" text not null,
    mod_de timestamp constraint tbl_int_machine_prod_declar_line_df_ts default current_timestamp not null,
    constraint tbl_int_machine_prod_declar_line_pk primary key ("Machine Center No_", "Date", "Work Shift", "Line No_")
);
raise notice '************************************';

/* 0025.02 */
raise notice 'creating table "tbl_int_machine_prod_declar_line_load"';
create table if not exists nav.tbl_int_machine_prod_declar_line_load(
    "timestamp" bigint not null,
    "Machine Center No_" text not null,
    "Date" timestamp not null,
    "Work Shift" int not null,
    "Line No_" int not null,
    "Prod_ Order No_" text not null,
    "Prod_ Order Line" int not null,
    "Routing No_" text not null,
    "Operation No_" text not null,
    "Prod_ Order Item No_" text not null,
    "Setup Start" timestamp not null,
    "Setup End" timestamp not null,
    "Run Start" timestamp not null,
    "Run End" timestamp not null,
    "Runtime Min_" decimal(38, 20) not null,
    "Setup Time Min_" decimal(38, 20) not null,
    "Conf_ Qty_" decimal(38, 20) not null,
    "Scrap Qty_" decimal(38, 20) not null,
    "No_of Workers" int not null,
    "Time per Piece" decimal(38, 20) not null,
    "Scrap Code" text not null,
    "Scrap Commets" text not null,
    "Repair Code" text not null,
    mod_de timestamp constraint tbl_int_machine_prod_declar_line_load_df_ts default current_timestamp not null,
    constraint tbl_int_machine_prod_declar_line_load_pk primary key ("Machine Center No_", "Date", "Work Shift", "Line No_")
);
raise notice '************************************';

/* 0026.01 */
raise notice 'creating table "tbl_int_machine_prod_declar_indir_time"';
create table if not exists nav.tbl_int_machine_prod_declar_indir_time(
    "timestamp" bigint not null,
    "Machine Center No_" text not null,
    "Date" timestamp not null,
    "Work Shift" int not null,
    "Line No_" int not null,
    "Stop Code" text not null,
    "Observations" text not null,
    "Stop Start" timestamp not null,
    "Stop End" timestamp not null,
    "Indirect Time Min_" decimal(38, 20) not null,
    "No_of Workers" int not null,
    "Item No_ Stacked" text not null,
    mod_de timestamp constraint tbl_int_machine_prod_declar_indir_time_df_ts default current_timestamp not null,
    constraint tbl_int_machine_prod_declar_indir_time_pk primary key ("Machine Center No_", "Date", "Work Shift", "Line No_")
);
raise notice '************************************';

/* 0026.02 */
raise notice 'creating table "tbl_int_machine_prod_declar_indir_time_load"';
create table if not exists nav.tbl_int_machine_prod_declar_indir_time_load(
    "timestamp" bigint not null,
    "Machine Center No_" text not null,
    "Date" timestamp not null,
    "Work Shift" int not null,
    "Line No_" int not null,
    "Stop Code" text not null,
    "Observations" text not null,
    "Stop Start" timestamp not null,
    "Stop End" timestamp not null,
    "Indirect Time Min_" decimal(38, 20) not null,
    "No_of Workers" int not null,
    "Item No_ Stacked" text not null,
    mod_de timestamp constraint tbl_int_machine_prod_declar_indir_time_load_df_ts default current_timestamp not null,
    constraint tbl_int_machine_prod_declar_indir_time_load_pk primary key ("Machine Center No_", "Date", "Work Shift", "Line No_")
);
raise notice '************************************';

/* 0027.01 */
raise notice 'creating table "tbl_int_vendor"';
create table if not exists nav.tbl_int_vendor(
    "timestamp" bigint not null,
	"No_" text not null,
	"Name" text not null,
	"Search Name" text not null,
	"Name 2" text not null,
	"Address" text not null,
	"Address 2" text not null,
	"City" text not null,
	"Contact" text not null,
	"Phone No_" text not null,
	"Telex No_" text not null,
	"Our Account No_" text not null,
	"Territory Code" text not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"Budgeted Amount" decimal(38, 20) not null,
	"Vendor Posting Group" text not null,
	"Currency Code" text not null,
	"Language Code" text not null,
	"Statistics Group" int not null,
	"Payment Terms Code" text not null,
	"Fin_ Charge Terms Code" text not null,
	"Purchaser Code" text not null,
	"Shipment Method Code" text not null,
	"Shipping Agent Code" text not null,
	"Invoice Disc_ Code" text not null,
	"Country_Region Code" text not null,
	"Blocked" int not null,
	"Pay-to Vendor No_" text not null,
	"Priority" int not null,
	"Payment Method Code" text not null,
	"Last Date Modified" timestamp not null,
	"Application Method" int not null,
	"Prices Including VAT" smallint not null,
	"Fax No_" text not null,
	"Telex Answer Back" text not null,
	"VAT Registration No_" text not null,
	"Gen_ Bus_ Posting Group" text not null,
	"GLN" text not null,
	"Post Code" text not null,
	"County" text not null,
	"E-Mail" text not null,
	"Home Page" text not null,
	"No_ Series" text not null,
	"Tax Area Code" text not null,
	"Tax Liable" smallint not null,
	"VAT Bus_ Posting Group" text not null,
	"Block Payment Tolerance" smallint not null,
	"IC Partner Code" text not null,
	"Prepayment _" decimal(38, 20) not null,
	"Partner Type" int not null,
	"Creditor No_" text not null,
	"Preferred Bank Account Code" text not null,
	"Cash Flow Payment Terms Code" text not null,
	"Primary Contact No_" text not null,
	"Responsibility Center" text not null,
	"Location Code" text not null,
	"Lead Time Calculation" text not null,
	"Base Calendar Code" text not null,
	"Document Sending Profile" text not null,
	"Identificator fabrica" text not null,
	"Default Bank Account Code" text not null,
	"Not VAT Registered" smallint not null,
	"Registration No_" text not null,
	"Commerce Trade No_" text not null,
	"Transaction Type" text not null,
	"Transaction Specification" text not null,
	"Transport Method" text not null,
	"Currency Transformation Index" int not null,
	"VAT to Pay" smallint not null,
	"Tip Partener" int not null,
	"Cod Judet D394" int not null,
	"Organization type" int not null,
	"Data inceput Split TVA" timestamp not null,
	"Data inceput TVA de plata" timestamp not null,
	"Data inceput TVA" timestamp not null,
	"Data sfarsit TVA" timestamp not null,
	"Data sfarsit TVA de plata" timestamp not null,
	"Inactiv" smallint not null,
	"Data inactivare" timestamp not null,
	"Data Reactivare" timestamp not null,
	"Data anulare Split TVA" timestamp not null,
	"Registru Plati Defalcate" smallint not null,
    mod_de timestamp constraint tbl_int_vendor_df_ts default current_timestamp not null,
    constraint tbl_int_vendor_pk primary key ("No_")
);
create unique index if not exists tbl_int_vendor_ix1 on nav.tbl_int_vendor ("timestamp");
raise notice '************************************';

/* 0027.02 */
raise notice 'creating table "tbl_int_vendor_load"';
create table if not exists nav.tbl_int_vendor_load(
    "timestamp" bigint not null,
	"No_" text not null,
	"Name" text not null,
	"Search Name" text not null,
	"Name 2" text not null,
	"Address" text not null,
	"Address 2" text not null,
	"City" text not null,
	"Contact" text not null,
	"Phone No_" text not null,
	"Telex No_" text not null,
	"Our Account No_" text not null,
	"Territory Code" text not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"Budgeted Amount" decimal(38, 20) not null,
	"Vendor Posting Group" text not null,
	"Currency Code" text not null,
	"Language Code" text not null,
	"Statistics Group" int not null,
	"Payment Terms Code" text not null,
	"Fin_ Charge Terms Code" text not null,
	"Purchaser Code" text not null,
	"Shipment Method Code" text not null,
	"Shipping Agent Code" text not null,
	"Invoice Disc_ Code" text not null,
	"Country_Region Code" text not null,
	"Blocked" int not null,
	"Pay-to Vendor No_" text not null,
	"Priority" int not null,
	"Payment Method Code" text not null,
	"Last Date Modified" timestamp not null,
	"Application Method" int not null,
	"Prices Including VAT" smallint not null,
	"Fax No_" text not null,
	"Telex Answer Back" text not null,
	"VAT Registration No_" text not null,
	"Gen_ Bus_ Posting Group" text not null,
	"GLN" text not null,
	"Post Code" text not null,
	"County" text not null,
	"E-Mail" text not null,
	"Home Page" text not null,
	"No_ Series" text not null,
	"Tax Area Code" text not null,
	"Tax Liable" smallint not null,
	"VAT Bus_ Posting Group" text not null,
	"Block Payment Tolerance" smallint not null,
	"IC Partner Code" text not null,
	"Prepayment _" decimal(38, 20) not null,
	"Partner Type" int not null,
	"Creditor No_" text not null,
	"Preferred Bank Account Code" text not null,
	"Cash Flow Payment Terms Code" text not null,
	"Primary Contact No_" text not null,
	"Responsibility Center" text not null,
	"Location Code" text not null,
	"Lead Time Calculation" text not null,
	"Base Calendar Code" text not null,
	"Document Sending Profile" text not null,
	"Identificator fabrica" text not null,
	"Default Bank Account Code" text not null,
	"Not VAT Registered" smallint not null,
	"Registration No_" text not null,
	"Commerce Trade No_" text not null,
	"Transaction Type" text not null,
	"Transaction Specification" text not null,
	"Transport Method" text not null,
	"Currency Transformation Index" int not null,
	"VAT to Pay" smallint not null,
	"Tip Partener" int not null,
	"Cod Judet D394" int not null,
	"Organization type" int not null,
	"Data inceput Split TVA" timestamp not null,
	"Data inceput TVA de plata" timestamp not null,
	"Data inceput TVA" timestamp not null,
	"Data sfarsit TVA" timestamp not null,
	"Data sfarsit TVA de plata" timestamp not null,
	"Inactiv" smallint not null,
	"Data inactivare" timestamp not null,
	"Data Reactivare" timestamp not null,
	"Data anulare Split TVA" timestamp not null,
	"Registru Plati Defalcate" smallint not null,
    mod_de timestamp constraint tbl_int_vendor_load_df_ts default current_timestamp not null,
    constraint tbl_int_vendor_load_pk primary key ("No_")
);
raise notice '************************************';

/* 0027.03 */
raise notice 'creating table "tbl_int_vendor_blocked"';
create table if not exists nav.tbl_int_vendor_blocked(
	"Blocked" int not null,
	"Description" text not null,
	constraint tbl_int_vendor_blocked_pk primary key ("Blocked")
);
insert into nav.tbl_int_vendor_blocked ("Blocked", "Description")
values (1, 'Payment'), (2, 'All')
on conflict on constraint tbl_int_vendor_blocked_pk do nothing;

raise notice '************************************';

/* 0027.04 */
raise notice 'creating table "tbl_int_vendor_application_method"';
create table if not exists nav.tbl_int_vendor_application_method(
	"Application Method" int not null,
	"Description" text not null,
	constraint tbl_int_vendor_application_method_pk primary key ("Application Method")
);
insert into nav.tbl_int_vendor_application_method ("Application Method", "Description")
values (0, 'Manual'), (1, 'Apply to Oldest')
on conflict on constraint tbl_int_vendor_application_method_pk do nothing;

raise notice '************************************';

/* 0027.05 */
raise notice 'creating table "tbl_int_vendor_partner_type"';
create table if not exists nav.tbl_int_vendor_partner_type(
	"Partner Type" int not null,
	"Description" text not null,
	constraint tbl_int_vendor_partner_type_pk primary key ("Partner Type")
);
insert into nav.tbl_int_vendor_partner_type ("Partner Type", "Description")
values (1, 'Company'), (2, 'Person')
on conflict on constraint tbl_int_vendor_partner_type_pk do nothing;

raise notice '************************************';

/* 0028.01 */
raise notice 'creating table "tbl_int_gl_account"';
create table if not exists nav.tbl_int_gl_account(
    "timestamp" bigint not null,
	"No_" text not null,
	"Name" text not null,
	"Search Name" text not null,
	"Account Type" int not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"Account Category" int not null,
	"Income_Balance" int not null,
	"Debit_Credit" int not null,
	"No_ 2" text not null,
	"Blocked" smallint not null,
	"Direct Posting" smallint not null,
	"Reconciliation Account" smallint not null,
	"New Page" smallint not null,
	"No_ of Blank Lines" int not null,
	"Indentation" int not null,
	"Last Date Modified" timestamp not null,
	"Totaling" text not null,
	"Consol_ Translation Method" int not null,
	"Consol_ Debit Acc_" text not null,
	"Consol_ Credit Acc_" text not null,
	"Gen_ Posting Type" int not null,
	"Gen_ Bus_ Posting Group" text not null,
	"Gen_ Prod_ Posting Group" text not null,
	"Automatic Ext_ Texts" smallint not null,
	"Tax Area Code" text not null,
	"Tax Liable" smallint not null,
	"Tax Group Code" text not null,
	"VAT Bus_ Posting Group" text not null,
	"VAT Prod_ Posting Group" text not null,
	"Exchange Rate Adjustment" int not null,
	"Default IC Partner G_L Acc_ No" text not null,
	"Omit Default Descr_ in Jnl_" smallint not null,
	"Account Subcategory Entry No_" int not null,
	"Cost Type No_" text not null,
	"Default Deferral Template Code" text not null,
	"Analytic_Synthetic1_Synthetic2" int not null,
	"Closing Account" text not null,
	"Check Posting Debit_Credit" smallint not null,
    mod_de timestamp constraint tbl_int_gl_account_df_ts default current_timestamp not null,
    constraint tbl_int_gl_account_pk primary key ("No_")
);
create unique index if not exists tbl_int_gl_account_ix1 on nav.tbl_int_gl_account ("timestamp");
raise notice '************************************';

/* 0028.02 */
raise notice 'creating table "tbl_int_gl_account_load"';
create table if not exists nav.tbl_int_gl_account_load(
    "timestamp" bigint not null,
	"No_" text not null,
	"Name" text not null,
	"Search Name" text not null,
	"Account Type" int not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"Account Category" int not null,
	"Income_Balance" int not null,
	"Debit_Credit" int not null,
	"No_ 2" text not null,
	"Blocked" smallint not null,
	"Direct Posting" smallint not null,
	"Reconciliation Account" smallint not null,
	"New Page" smallint not null,
	"No_ of Blank Lines" int not null,
	"Indentation" int not null,
	"Last Date Modified" timestamp not null,
	"Totaling" text not null,
	"Consol_ Translation Method" int not null,
	"Consol_ Debit Acc_" text not null,
	"Consol_ Credit Acc_" text not null,
	"Gen_ Posting Type" int not null,
	"Gen_ Bus_ Posting Group" text not null,
	"Gen_ Prod_ Posting Group" text not null,
	"Automatic Ext_ Texts" smallint not null,
	"Tax Area Code" text not null,
	"Tax Liable" smallint not null,
	"Tax Group Code" text not null,
	"VAT Bus_ Posting Group" text not null,
	"VAT Prod_ Posting Group" text not null,
	"Exchange Rate Adjustment" int not null,
	"Default IC Partner G_L Acc_ No" text not null,
	"Omit Default Descr_ in Jnl_" smallint not null,
	"Account Subcategory Entry No_" int not null,
	"Cost Type No_" text not null,
	"Default Deferral Template Code" text not null,
	"Analytic_Synthetic1_Synthetic2" int not null,
	"Closing Account" text not null,
	"Check Posting Debit_Credit" smallint not null,
    mod_de timestamp constraint tbl_int_gl_account_load_df_ts default current_timestamp not null,
    constraint tbl_int_gl_account_load_pk primary key ("No_")
);
raise notice '************************************';

/* 0028.03 */
raise notice 'creating table "tbl_int_gl_account_type"';
create table if not exists nav.tbl_int_gl_account_type(
    "Account Type" int not null,
    "Description" text not null,
    constraint tbl_int_gl_account_type_pk primary key ("Account Type")
);
insert into nav.tbl_int_gl_account_type ("Account Type", "Description")
values (0, 'Posting'), (1, 'Heading'), (2, 'Total'), (3, 'Begin-Total'), (4, 'End-Total')
on conflict on constraint tbl_int_gl_account_type_pk do nothing;
raise notice '************************************';

/* 0028.04 */
raise notice 'creating table "tbl_int_gl_account_category"';
create table if not exists nav.tbl_int_gl_account_category(
    "Account Category" int not null,
    "Description" text not null,
    constraint tbl_int_gl_account_category_pk primary key ("Account Category")
);
insert into nav.tbl_int_gl_account_category ("Account Category", "Description")
values (1, 'Assets'), (2, 'Liabilities'), (3, 'Equity'), (4, 'Income'), (5, 'Cost of Goods Sold'), (6, 'Expense')
on conflict on constraint tbl_int_gl_account_category_pk do nothing;
raise notice '************************************';

/* 0028.05 */
raise notice 'creating table "tbl_int_gl_account_income_balance"';
create table if not exists nav.tbl_int_gl_account_income_balance(
    "Income_Balance" int not null,
    "Description" text not null,
    constraint tbl_int_gl_account_income_balance_pk primary key ("Income_Balance")
);
insert into nav.tbl_int_gl_account_income_balance ("Income_Balance", "Description")
values (0, 'Income Statement'), (1, 'Balance Sheet')
on conflict on constraint tbl_int_gl_account_income_balance_pk do nothing;
raise notice '************************************';

/* 0028.06 */
raise notice 'creating table "tbl_int_gl_account_debit_credit"';
create table if not exists nav.tbl_int_gl_account_debit_credit(
    "Debit_Credit" int not null,
    "Description" text not null,
    constraint tbl_int_gl_account_debit_credit_pk primary key ("Debit_Credit")
);
insert into nav.tbl_int_gl_account_debit_credit ("Debit_Credit", "Description")
values (0, 'Both'), (1, 'Debit'), (2, 'Credit')
on conflict on constraint tbl_int_gl_account_debit_credit_pk do nothing;
raise notice '************************************';

/* 0028.07 */
raise notice 'creating table "tbl_int_gl_account_consol_translation"';
create table if not exists nav.tbl_int_gl_account_consol_translation(
    "Consol_ Translation Method" int not null,
    "Description" text not null,
    constraint tbl_int_gl_account_consol_translation_pk primary key ("Consol_ Translation Method")
);
insert into nav.tbl_int_gl_account_consol_translation ("Consol_ Translation Method", "Description")
values (0, 'Average Rate (Manual)'), (1, 'Closing Rate'), (2, 'Historical Rate') ,(3, 'Composite Rate'), (4, 'Equity Rate')
on conflict on constraint tbl_int_gl_account_consol_translation_pk do nothing;
raise notice '************************************';

/* 0028.08 */
raise notice 'creating table "tbl_int_gl_account_exch_rate_adjmt"';
create table if not exists nav.tbl_int_gl_account_exch_rate_adjmt(
    "Exchange Rate Adjustment" int not null,
    "Description" text not null,
    constraint tbl_int_gl_account_exch_rate_adjmt_pk primary key ("Exchange Rate Adjustment")
);
insert into nav.tbl_int_gl_account_exch_rate_adjmt ("Exchange Rate Adjustment", "Description")
values (0, 'No Adjustment'), (1, 'Adjust Amount'), (2, 'Adjust Additional-Currency Amount')
on conflict on constraint tbl_int_gl_account_exch_rate_adjmt_pk do nothing;
raise notice '************************************';

/* 0029.01 */
raise notice 'creating table "tbl_int_gl_entry"';
create table if not exists nav.tbl_int_gl_entry(
    "timestamp" bigint not null,
	"Entry No_" int not null,
	"G_L Account No_" text not null,
	"Posting Date" timestamp not null,
	"Document Type" int not null,
	"Document No_" text not null,
	"Description" text not null,
	"Bal_ Account No_" text not null,
	"Amount" decimal(38, 20) not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"User ID" text not null,
	"Source Code" text not null,
	"System-Created Entry" smallint not null,
	"Prior-Year Entry" smallint not null,
	"Job No_" text not null,
	"Quantity" decimal(38, 20) not null,
	"VAT Amount" decimal(38, 20) not null,
	"Business Unit Code" text not null,
	"Journal Batch Name" text not null,
	"Reason Code" text not null,
	"Gen_ Posting Type" int not null,
	"Gen_ Bus_ Posting Group" text not null,
	"Gen_ Prod_ Posting Group" text not null,
	"Bal_ Account Type" int not null,
	"Transaction No_" int not null,
	"Debit Amount" decimal(38, 20) not null,
	"Credit Amount" decimal(38, 20) not null,
	"Document Date" timestamp not null,
	"External Document No_" text not null,
	"Source Type" int not null,
	"Source No_" text not null,
	"No_ Series" text not null,
	"Tax Area Code" text not null,
	"Tax Liable" smallint not null,
	"Tax Group Code" text not null,
	"Use Tax" smallint not null,
	"VAT Bus_ Posting Group" text not null,
	"VAT Prod_ Posting Group" text not null,
	"Additional-Currency Amount" decimal(38, 20) not null,
	"Add_-Currency Debit Amount" decimal(38, 20) not null,
	"Add_-Currency Credit Amount" decimal(38, 20) not null,
	"Close Income Statement Dim_ ID" int not null,
	"IC Partner Code" text not null,
	"Reversed" smallint not null,
	"Reversed by Entry No_" int not null,
	"Reversed Entry No_" int not null,
	"Dimension Set ID" int not null,
	"Prod_ Order No_" text not null,
	"FA Entry Type" int not null,
	"FA Entry No_" int not null,
	"Custom Invoice No_" text not null,
	"Transfer Self-Invoice" smallint not null,
	"Amount (FCY)" decimal(38, 20) not null,
	"Debit Amount (FCY)" decimal(38, 20) not null,
	"Credit Amount (FCY)" decimal(38, 20) not null,
	"Currency Code" text not null,
	"Currency Factor" decimal(38, 20) not null,
	"Value Entry No_" int not null,
    mod_de timestamp constraint tbl_int_gl_entry_df_ts default current_timestamp not null,
    constraint tbl_int_gl_entry_pk primary key ("Entry No_")
);
create index if not exists tbl_int_gl_entry_ix1 on nav.tbl_int_gl_entry ("Transaction No_", "Entry No_");
create index if not exists tbl_int_gl_entry_ix2 on nav.tbl_int_gl_entry ("Posting Date", "Transaction No_");
raise notice '************************************';

/* 0029.02 */
raise notice 'creating table "tbl_int_gl_entry_load"';
create table if not exists nav.tbl_int_gl_entry_load(
    "timestamp" bigint not null,
	"Entry No_" int not null,
	"G_L Account No_" text not null,
	"Posting Date" timestamp not null,
	"Document Type" int not null,
	"Document No_" text not null,
	"Description" text not null,
	"Bal_ Account No_" text not null,
	"Amount" decimal(38, 20) not null,
	"Global Dimension 1 Code" text not null,
	"Global Dimension 2 Code" text not null,
	"User ID" text not null,
	"Source Code" text not null,
	"System-Created Entry" smallint not null,
	"Prior-Year Entry" smallint not null,
	"Job No_" text not null,
	"Quantity" decimal(38, 20) not null,
	"VAT Amount" decimal(38, 20) not null,
	"Business Unit Code" text not null,
	"Journal Batch Name" text not null,
	"Reason Code" text not null,
	"Gen_ Posting Type" int not null,
	"Gen_ Bus_ Posting Group" text not null,
	"Gen_ Prod_ Posting Group" text not null,
	"Bal_ Account Type" int not null,
	"Transaction No_" int not null,
	"Debit Amount" decimal(38, 20) not null,
	"Credit Amount" decimal(38, 20) not null,
	"Document Date" timestamp not null,
	"External Document No_" text not null,
	"Source Type" int not null,
	"Source No_" text not null,
	"No_ Series" text not null,
	"Tax Area Code" text not null,
	"Tax Liable" smallint not null,
	"Tax Group Code" text not null,
	"Use Tax" smallint not null,
	"VAT Bus_ Posting Group" text not null,
	"VAT Prod_ Posting Group" text not null,
	"Additional-Currency Amount" decimal(38, 20) not null,
	"Add_-Currency Debit Amount" decimal(38, 20) not null,
	"Add_-Currency Credit Amount" decimal(38, 20) not null,
	"Close Income Statement Dim_ ID" int not null,
	"IC Partner Code" text not null,
	"Reversed" smallint not null,
	"Reversed by Entry No_" int not null,
	"Reversed Entry No_" int not null,
	"Dimension Set ID" int not null,
	"Prod_ Order No_" text not null,
	"FA Entry Type" int not null,
	"FA Entry No_" int not null,
	"Custom Invoice No_" text not null,
	"Transfer Self-Invoice" smallint not null,
	"Amount (FCY)" decimal(38, 20) not null,
	"Debit Amount (FCY)" decimal(38, 20) not null,
	"Credit Amount (FCY)" decimal(38, 20) not null,
	"Currency Code" text not null,
	"Currency Factor" decimal(38, 20) not null,
	"Value Entry No_" int not null,
    mod_de timestamp constraint tbl_int_gl_entry_load_df_ts default current_timestamp not null,
    constraint tbl_int_gl_entry_load_pk primary key ("Entry No_")
);
raise notice '************************************';

/* 0029.03 */
raise notice 'creating table "tbl_int_gl_entry_document_type"';
create table if not exists nav.tbl_int_gl_entry_document_type(
    "Document Type" int not null,
    "Description" text not null,
    constraint tbl_int_gl_entry_document_type_pk primary key ("Document Type")
);
insert into nav.tbl_int_gl_entry_document_type ("Document Type", "Description")
values (1, 'Payment'), (2, 'Invoice'), (3, 'Credit Memo'), (4, 'Finance Charge Memo'), (5, 'Reminder'), (6, 'Refund')
on conflict on constraint tbl_int_gl_entry_document_type_pk do nothing;
raise notice '************************************';

/* 0029.04 */
raise notice 'creating table "tbl_int_gl_entry_gen_posting_type"';
create table if not exists nav.tbl_int_gl_entry_gen_posting_type(
    "Gen_ Posting Type" int not null,
    "Description" text not null,
    constraint tbl_int_gl_entry_gen_posting_type_pk primary key ("Gen_ Posting Type")
);
insert into nav.tbl_int_gl_entry_gen_posting_type ("Gen_ Posting Type", "Description")
values (1, 'Purchase'), (2, 'Sale'), (3, 'Settlement')
on conflict on constraint tbl_int_gl_entry_gen_posting_type_pk do nothing;
raise notice '************************************';

/* 0029.05 */
raise notice 'creating table "tbl_int_gl_entry_bal_account_type"';
create table if not exists nav.tbl_int_gl_entry_bal_account_type(
    "Bal_ Account Type" int not null,
    "Description" text not null,
    constraint tbl_int_gl_entry_bal_account_type_pk primary key ("Bal_ Account Type")
);
insert into nav.tbl_int_gl_entry_bal_account_type ("Bal_ Account Type", "Description")
values (0, 'G/L Account'), (1, 'Customer') ,(2, 'Vendor') ,(3, 'Bank Account'), (4, 'Fixed Asset'), (5, 'IC Partner')
on conflict on constraint tbl_int_gl_entry_bal_account_type_pk do nothing;
raise notice '************************************';

/* 0029.06 */
raise notice 'creating table "tbl_int_gl_entry_source_type"';
create table if not exists nav.tbl_int_gl_entry_source_type(
    "Source Type" int not null,
    "Description" text not null,
    constraint tbl_int_gl_entry_source_type_pk primary key ("Source Type")
);
insert into nav.tbl_int_gl_entry_source_type ("Source Type", "Description")
values (1, 'Customer'), (2, 'Vendor'), (3, 'Bank Account') ,(4, 'Fixed Asset')
on conflict on constraint tbl_int_gl_entry_source_type_pk do nothing;
raise notice '************************************';

/* 0029.07 */
raise notice 'creating table "tbl_int_gl_entry_fa_entry_type"';
create table if not exists nav.tbl_int_gl_entry_fa_entry_type(
    "FA Entry Type" int not null,
    "Description" text not null,
    constraint tbl_int_gl_entry_fa_entry_type_pk primary key ("FA Entry Type")
);
insert into nav.tbl_int_gl_entry_fa_entry_type ("FA Entry Type", "Description")
values (1, 'Fixed Asset'), (2, 'Maintenance')
on conflict on constraint tbl_int_gl_entry_fa_entry_type_pk do nothing;
raise notice '************************************';

/* 0030.01 */
raise notice 'creating table "tbl_int_gl_item_ledger_relation"';
create table if not exists nav.tbl_int_gl_item_ledger_relation(
    "timestamp" bigint not null,
    "G_L Entry No_" int not null,
	"Value Entry No_" int not null,
	"G_L Register No_" int not null,
    mod_de timestamp constraint tbl_int_gl_item_ledger_relation_df_ts default current_timestamp not null,
    constraint tbl_int_gl_item_ledger_relation_pk primary key ("G_L Entry No_", "Value Entry No_")
);
create index if not exists tbl_int_gl_item_ledger_relation_ix1 on nav.tbl_int_gl_item_ledger_relation ("G_L Entry No_");
raise notice '************************************';

/* 0030.02 */
raise notice 'creating table "tbl_int_gl_item_ledger_relation_load"';
create table if not exists nav.tbl_int_gl_item_ledger_relation_load(
    "timestamp" bigint not null,
    "G_L Entry No_" int not null,
	"Value Entry No_" int not null,
	"G_L Register No_" int not null,
    mod_de timestamp constraint tbl_int_gl_item_ledger_relation_load_df_ts default current_timestamp not null,
    constraint tbl_int_gl_item_ledger_relation_load_pk primary key ("G_L Entry No_", "Value Entry No_")
);
raise notice '************************************';

/* code block ending*/
end;
$$ language plpgsql;