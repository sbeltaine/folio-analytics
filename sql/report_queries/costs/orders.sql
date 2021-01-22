/**
 
 
 Meeting topics...
 -derived tables: subscription to and from, tags
 -more fields: workflow-status and renewal date (where is this?)
 -filters: date, order type, subscription
 

PURPOSE
The purpose of this report is to provide details about each purchase order with filtering by date and/or order type.

MAIN TABLES AND COLUMNS INCLUDED

-po_lines
	-purchase order line id
	-purchase_order_number from po_lines_id
	-tags (data array)
	-description
	-acquisition method
	-subscription from and subscription to (json extract text - see "interesting times" data row)
	-material type (derived table)
	-instanceid
	-agreementid
	
-po_purchase_orders
	-order_type
	-approval_date
	-workflow-status
	-acquisition_unit_ids (data array)
	-subtotal
	
	
-invoice_lines
	-invoice_id
	-invoice_line_number
	-po_line_id (JOIN on this)
	
	
AGGREGATION


	
FILTERS FOR USERS TO SELECT
date filter on approval_date
order type
workflow status: can be set to pending, open, or closed
tags: local field with custom settings	

HARDCODED FILTERS		


STILL IN PROGRESS
						
NOTE
-order type is at the po_purchase_orders and can be One-Time or Ongoing
-still need a date to filter on...set up as a filter for created or updated from data array in po_purchase_orders
-subscription to and from only applies to Ongoing order type
-fund and encumbrance info is split on the po line by electronic and physical
-consider creating one derived table for both electronic and physical material type (later); Nancy creating

ADD
-renewal date and workflow status from PO purchase order table; renewal date is only there if order type is ongoing
-need another derived table to show ongoing status with renewal dates from po_purchase_orders
-filter on workflow status (e.g., pending, open, closed)
-updated date and created date (data array from po_purchase_order)	
-create a po_tags derived table and join to it from po line id to limit number of tags to po line; 
include as filter, user will need to enter tag being sought
-date_ordered for date field from po_purchase_orders	

DOCUMENT
-add information on using created and updated date from po_purchase_orders data array, 
but use approval_date as the main date data element
-acquisition unit is optional for institutions to implement
-need to think about prefixes and suffixes for po line number (optional)
-some POs have both electronic and physical material type on the same PO; these are divided by PO line
-subscription to and from are changeable filters, not part of the results set

					
*/
--updated to use date
WITH parameters AS (
    SELECT
        '2000-01-01' :: DATE AS start_date,
        '2021-01-01' :: DATE AS end_date,
        '' :: VARCHAR AS workflow_status,
        '' :: VARCHAR AS order_type,
        '2000-01-01' :: DATE AS subscription_from_date,
        '2021-01-01' :: DATE AS subscription_to_date
),

--subquery for po_lines_detail
 po_lines_detail AS (
SELECT
	pol.id AS "po_lines_id",
	pol.po_line_number AS "pol_po_line_number",
	--need derived table for tags
	--pol.tags AS "purchase_order_tags",	
	pol.description AS "pol_purchase_order_description",
	pol.acquisition_method AS "pol_purchase_order_acquisition_method",
	--need po_lines_subscription_range derived table
	--pol.subscription_from AS "pol_subscription_from",
	--pol.subscription_to AS "pol_subscription_to",
	--pol.subscription_interval as "pol_subscription_interval",
	polermat.pol_er_mat_type_name AS "purchase_order_elec_material_type_name",
	polphysmat.pol_mat_type_name AS "purchase_order_phys_material_type_name",
	--pol.instance_id AS "purchase_order_instance_id", --need to see if instance id is available
	pol.agreement_id AS "purchase_order_agreement_id",
	pol.purchase_order_id
	
FROM po_lines AS pol
LEFT JOIN folio_reporting.po_lines_er_mat_type AS polermat
ON pol.id = polermat.pol_id
LEFT JOIN folio_reporting.po_lines_phys_mat_type AS polphysmat
ON pol.id = polphysmat.pol_id
--LEFT JOIN folio_reporting.po_lines_tags AS poltags
--ON pol.id = poltags.pol_id
--LEFT JOIN folio_reporting.po_lines_details_subscriptions AS polsubdtl
--ON pol.id = polsubdtl.pol.id

),

--subquery for po_purchase_order_detail
po_purchase_order_detail AS (
SELECT
	podtl.id AS "purchaseorder_detail_id",
	podtl.order_type AS "po_order_type",
	podtl.po_number AS "po_number",
	podtl.workflow_status AS "po_workflow_status",
	poacqunitids.po_acquisition_unit_id AS "po_acquisition_unit_id",
	poacqunitids.po_acquisition_unit_name AS "po_acquisition_unit_name"
	--renewal date
	
FROM po_purchase_orders AS podtl

LEFT JOIN folio_reporting.po_acq_unit_ids AS poacqunitids
ON podtl.id = poacqunitids.po_id

--Add new subquery here
--use po_line_id in invoice_lines to join to po_lines, get po_line_number from po_lines

)

/*

)*/
-- End of WITH section


--MAIN QUERY: provide details about each purchase order with filtering by date and/or order type
--starts from po_lines_detail subquery
SELECT 
	pol_po_line_number,
	po_order_type,
	--purchase_order_tags?
	po_acquisition_unit_name,
	pol_purchase_order_description,
	pol_purchase_order_acquisition_method,
	--subscription to AS "pol_subscription_to"?
	--subscription from AS "pol_subscription_from"?
	purchase_order_elec_material_type_name,
	purchase_order_phys_material_type_name,
	--purchase_order_instance_id,
	purchase_order_agreement_id
	--renewal_date?
	--workflow-status?

FROM po_lines_detail AS pol
	
--LEFT JOIN po_line_detail AS "pol_detail"
--ON pol_detail.pol_id = po_line_detail.po_line_id
--pull the purchase order related data by joining tables
LEFT JOIN po_purchase_order_detail AS podtl
	ON podtl.purchaseorder_detail_id = pol.purchase_order_id

--filter po by order type and date
WHERE
	--order type = One-Time or Ongoing
	--AND subscription to (SELECT start_date FROM parameters) AND 
		--subscription from < (SELECT end_date FROM parameters))
	--AND
	(podtl.po_workflow_status = (SELECT workflow_status FROM parameters)) OR 
		((SELECT workflow_status FROM parameters) = '')
	AND 
	(po_order_type = (SELECT order_type FROM parameters)) OR 
		((SELECT order_type FROM parameters) = '')
	AND 
	--pol.pol_subscription_to >= (SELECT subscription_from_date FROM parameters) AND 
	--	pol.pol_subscription_from <= (SELECT subscription_to_date FROM parameters))
	AND 
	pol.pol_subscription_to >= (SELECT subscription_from_date FROM parameters) AND 
		pol.pol_subscription_from <= (SELECT subscription_to_date FROM parameters))
		
--GROUP BY
	--pol_po_line_number,
	--po_order_type,
	--pol_purchase_order_acquisition_method,
	--purchase_order_elec_material_type_name,
	--purchase_order_phys_material_type_name
	
	;




	
	
	

				
		
	
	


