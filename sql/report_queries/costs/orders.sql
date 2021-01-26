/**
 
 Next Steps
  -wait on adding agreement id? YES
 -reviewers?
 -ask Nassib about date_ordered and instance_id, it is not in current folio_snapshot

PURPOSE
The purpose of this report is to provide details about each purchase order. 
It allows filtering by date, order type, tags, and workflow status. 
The data are aggregated by purchase order, acquisition method, and material type.

MAIN TABLES AND COLUMNS INCLUDED

-po_lines
	-purchase order line id
	-purchase_order_number from po_lines_id
	-tags (data array)
	-description
	-acquisition method
	-subscription from
	-subscription to 
	-subscription interval (json extract text - see "interesting times" data row)
	-material type (data array)
	-instanceid
	
-po_purchase_orders
	-order_type
	-approval_date
	-workflow-status
	-acquisition_unit_ids (data array)
	-subtotal

-invoice_lines
	-invoice_id
	-invoice_line_number
	-po_line_id
	
AGGREGATION
This query aggregates the data by 
	--pol_po_line_number,
	--po_order_type,
	--pol_purchase_order_acquisition_method,
	--purchase_order_elec_material_type_name,
	--purchase_order_phys_material_type_name
	
FILTERS FOR USERS TO SELECT
date: filters data using the date_ordered field on purchase orders
order type: can be set to One-Time or Ongoing; "subscription to," subscription from" and "subscription interval" data only shows for One-Time order type; renewal date is only present if order type is Ongoing
workflow status: can be set to pending, open, or closed
tags: local field with custom settings	

HARDCODED FILTERS


OPTIONAL FIELDS
acquistion unit id and acquisition unit name: these fields will only show data if the institution has elected to use them
		
DOCUMENT
-acquisition unit id and name are optional for institutions to implement
-some POs have both electronic and physical material type on the same PO; these are divided by PO line
-subscription to and from are changeable filters, not part of the results set
-subscription data entry is optional for institutions

STILL IN PROGRESS
-need to add paymentDate field from invoices data array when available
-consider creating one derived table for both electronic and physical material type (later); Nancy creating
-need to think about prefixes and suffixes for po line number (optional)
-add agreement_id; agreements order line to entitlement to agreement; resource type is on the entitlements table

SEPARATE QUERIES
-what subscriptions have I paid for this year?
-what subscriptions have I not paid for this year?
-need ongoing orders with outstanding payments with subsets for subscription and not subscriptions (another query)

					
*/
--updated to use date
WITH parameters AS (
    SELECT
        '2000-01-01' :: DATE AS start_date,
        '2021-01-01' :: DATE AS end_date,
        '' :: VARCHAR AS workflow_status,
        '' :: VARCHAR AS order_type,
        -- Please comment/uncomment one pair the these NULL parameters if you want to define the range of active subscriptions  
       	NULL :: DATE AS subscription_from_date,
        NULL :: DATE AS subscription_to_date,
        --'2000-01-01' :: DATE AS subscription_from_date,
   	    --'2021-01-01' :: DATE AS subscription_to_date,     
        ''::VARCHAR AS tags_filter1, -- select 'your first local tag' or leave blank for all. You can use %% as wildcards.
        ''::VARCHAR AS tags_filter2, -- select 'your second local tag' or leave blank for all. You can use %% as wildcards.
        ''::VARCHAR AS tags_filter3 --select 'your third local tag' or leave blank for all. You can use %% as wildcards.

),

--subquery for po_lines_detail
 po_lines_detail AS (
SELECT
	pol.id AS "po_line_id",
	pol.po_line_number AS "po_line_number",
	poltags.pol_tag AS "purchase_order_tag",
	pol.description AS "purchase_order_description",
	pol.acquisition_method AS "purchase_order_acquisition_method",
	polsubdtl.pol_subscription_from AS "pol_subscription_from",
	polsubdtl.pol_subscription_to AS "pol_subscription_to",
	polsubdtl.pol_subscription_interval as "pol_subscription_interval",
	polermat.pol_er_mat_type_name AS "purchase_order_elec_material_type_name",
	polphysmat.pol_mat_type_name AS "purchase_order_phys_material_type_name",
	--pol.instance_id AS "instance_id",
	pol.agreement_id AS "agreement_id",
	pol.purchase_order_id AS "purchase_order_id"
	
FROM po_lines AS pol
LEFT JOIN folio_reporting.po_lines_er_mat_type AS polermat
ON pol.id = polermat.pol_id
LEFT JOIN folio_reporting.po_lines_phys_mat_type AS polphysmat
ON pol.id = polphysmat.pol_id
LEFT JOIN folio_reporting.po_lines_tags AS poltags
ON pol.id = poltags.pol_id
LEFT JOIN folio_reporting.po_lines_details_subscription AS polsubdtl
ON pol.id = polsubdtl.pol_id

),

--subquery for po_purchase_order_detail
po_purchase_order_detail AS (
SELECT
	podtl.id AS "po_detail_id",
	podtl.order_type AS "po_order_type",
	podtl.po_number AS "po_number",
	--podtl.date_ordered AS "po_date_ordered",
	podtl.workflow_status AS "po_workflow_status",
	poacqunitids.po_acquisition_unit_id AS "po_acquisition_unit_id",
	poacqunitids.po_acquisition_unit_name AS "po_acquisition_unit_name",
	poonging.po_ongoing_interval AS "po_ongoing_interval",
	poonging.po_ongoing_is_subscription AS "po_is_subscription",
	poonging.po_ongoing_renewal_date AS "po_renewal date",
	poonging.po_ongoing_review_period AS "po_review_period"
	
FROM po_purchase_orders AS podtl
LEFT JOIN folio_reporting.po_acq_unit_ids AS poacqunitids
ON podtl.id = poacqunitids.po_id
LEFT JOIN folio_reporting.po_ongoing AS poonging
ON podtl.id = poonging.po_id

)

--subquery for invoice line data	
--po_invoice_lines AS (
--SELECT 
	--poinvli.invoice_id AS "invoice_id",
	--poinvli.invoice_line_number AS "invoice_line_number",
	--poinvli.invoice_line_status AS "invoice_line_status",
	--poinvli.po_line_id AS "po_line_id"

--FROM invoice_lines AS poinvli


/*

)*/
-- End of WITH section


--MAIN QUERY: provide details about each purchase order with filtering by date and/or order type
--starts from po_lines_detail subquery
SELECT 
	po_line_number,
	purchase_order_description,
	po_order_type,
	--purchase_order_tags? NO
	--podtl.po_number AS "po_number",NO
	purchase_order_acquisition_method,
	po_acquisition_unit_name,
	--subscription_to?NO
	--subscription_from?NO
	--subscription_interval?NO
	purchase_order_elec_material_type_name,
	purchase_order_phys_material_type_name
	--instance_id,
	--agreement_id
	--renewal_date?
	--podtl.workflow_status AS "po_workflow_status"? NO
	--poonging.po_ongoing_interval AS "po_ongoing_interval", NO
	--poonging.po_ongoing_is_subscription AS "po_is_subscription", NO
	--poonging.po_ongoing_renewal_date AS "po_renewal date", NO
	--poonging.po_ongoing_review_period AS "po_review_period" NO
 	--nothing from invoice_lines
	
/*
 
 	--
 
 
 */	
	
	

FROM po_lines_detail AS pol
	
LEFT JOIN po_purchase_order_detail AS podtl
	ON podtl.po_detail_id = pol.purchase_order_id
	


--filter po by order type and date
WHERE
	--3 options for filtering on tags
--	 (podtl.po_date_ordered > (SELECT start_date FROM parameters) AND 
--		podtl.po_date_ordered < (SELECT end_date FROM parameters))
--	AND
	((podtl.po_workflow_status = (SELECT workflow_status FROM parameters)) OR 
		((SELECT workflow_status FROM parameters) = ''))
	AND 
	((po_order_type = (SELECT order_type FROM parameters)) OR 
		((SELECT order_type FROM parameters) = ''))
	AND 
	((pol.pol_subscription_to >= (SELECT subscription_from_date FROM parameters) OR 
		pol.pol_subscription_from <= (SELECT subscription_to_date FROM parameters))			
		OR 
		(((SELECT subscription_to_date FROM parameters) IS NULL) 
			OR ((SELECT subscription_from_date FROM parameters) IS NULL)))	
	AND 	
	(
		(pol.purchase_order_tag LIKE (SELECT tags_filter1 FROM parameters)
			OR pol.purchase_order_tag LIKE (SELECT tags_filter2 FROM parameters)
			OR pol.purchase_order_tag LIKE (SELECT tags_filter3 FROM parameters))
		OR 
		(
			(SELECT tags_filter1 FROM parameters) = ''
			AND (SELECT tags_filter2 FROM parameters) = ''
			AND (SELECT tags_filter3 FROM parameters) = ''))
		
--GROUP BY
	--po_line_number,
	--order_type,
	--purchase_order_acquisition_method,
	--purchase_order_elec_material_type_name,
	--purchase_order_phys_material_type_name
	
	;




	
	
	

				
		
	
	



	
	
	

				
		
	
	


