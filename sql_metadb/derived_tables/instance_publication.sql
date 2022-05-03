-- This derived table extracts publication information from the FOLIO instance record
DROP TABLE IF EXISTS instance_publication;

CREATE TABLE instance_publication AS 
SELECT 
	it.id AS instance_id,
	it.hrid as instance_hrid,
	jsonb_extract_path_text(pub.jsonb, 'place') AS publication_place,
	jsonb_extract_path_text(pub.jsonb, 'publisher') AS publisher,
	jsonb_extract_path_text(pub.jsonb, 'role') AS publication_role,
	jsonb_extract_path_text(pub.jsonb, 'dateOfPublication') AS date_of_publication,
	pub.ordinality AS publication_ordinality
FROM 
	folio_inventory.instance__t AS it
	LEFT JOIN folio_inventory.instance as inst on inst.id::uuid  = it.id::uuid 
	CROSS JOIN LATERAL jsonb_array_elements(jsonb_extract_path(inst.jsonb, 'publication')) WITH ORDINALITY AS pub (jsonb);

CREATE INDEX ON instance_publication (instance_id);

CREATE INDEX ON instance_publication (instance_hrid);

CREATE INDEX ON instance_publication (publication_place);

CREATE INDEX ON instance_publication (publisher);

CREATE INDEX ON instance_publication (publication_role);

CREATE INDEX ON instance_publication (date_of_publication);

CREATE INDEX ON instance_publication (publication_ordinality);

VACUUM ANALYZE instance_publication;
