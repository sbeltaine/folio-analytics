/* FIELDS TO INCLUDE:
Parameters
 date_range
Loans table
 loan_date
Groups table
 patron_group_name
Material Types table
 material_type_name
Locations table
 perm_location_name
 temp_location_name
 effective_location_name
Institutions table
 institution_name
Campuses table
 campus_name
Libraries table
 library_name

Aggregation: none

Filters:
 start_date (for loan_date)
 end_date (for loan_date)
 material_type_filter
 items_permament_location_filter
 items_temporary_location_filter
 items_effective_location_filter
 institution_filter
 campus_filter
 library_filter
 */
WITH parameters AS (
    SELECT
        /* Choose a start and end date for the loans period */
        '2000-01-01'::date AS start_date,
        '2022-01-01'::date AS end_date,
        /* Fill in a material type name, or leave blank for all types */
        ''::varchar AS material_type_filter,
        /* Fill in a location name, or leave blank for all locations */
        ''::varchar AS items_permanent_location_filter, --Online, Annex, Main Library
        ''::varchar AS items_temporary_location_filter, --Online, Annex, Main Library
        ''::varchar AS items_effective_location_filter, --Online, Annex, Main Library
        ''::varchar AS items_permanent_institution_filter, -- 'KÃ¸benhavns Universitet','Montoya College'
        ''::varchar AS items_permanent_campus_filter, -- 'Main Campus','City Campus','Online'
        ''::varchar AS items_permanent_library_filter -- 'Datalogisk Institut','Adelaide Library'
)
SELECT
    (
        SELECT
            start_date::varchar
        FROM
            parameters) || ' to '::varchar || (
        SELECT
            end_date::varchar
        FROM
            parameters) AS date_range,
    loan_date,
    patron_group_name,
    material_type_name,
    current_item_permanent_location_name AS perm_location_name,
    current_item_temporary_location_name AS temp_location_name,
    current_item_effective_location_name AS effective_location_name,
    current_item_permanent_location_library_name AS library_name,
    current_item_permanent_location_campus_name AS campus_name,
    current_item_permanent_location_institution_name AS institution_name
FROM
    folio_reporting.loans_items AS li
WHERE
    loan_date >= (
        SELECT
            start_date
        FROM
            parameters)
    AND loan_date < (
        SELECT
            end_date
        FROM
            parameters)
    AND (material_type_name = (
            SELECT
                material_type_filter
            FROM
                parameters)
            OR '' = (
                SELECT
                    material_type_filter
                FROM
                    parameters))
        AND (current_item_permanent_location_name = (
                SELECT
                    items_permanent_location_filter
                FROM
                    parameters)
                OR '' = (
                    SELECT
                        items_permanent_location_filter
                    FROM
                        parameters))
            AND (current_item_temporary_location_name = (
                    SELECT
                        items_temporary_location_filter
                    FROM
                        parameters)
                    OR '' = (
                        SELECT
                            items_temporary_location_filter
                        FROM
                            parameters))
                AND (current_item_effective_location_name = (
                        SELECT
                            items_effective_location_filter
                        FROM
                            parameters)
                        OR '' = (
                            SELECT
                                items_effective_location_filter
                            FROM
                                parameters))
                    AND (current_item_permanent_location_library_name = (
                            SELECT
                                items_permanent_library_filter
                            FROM
                                parameters)
                            OR '' = (
                                SELECT
                                    items_permanent_library_filter
                                FROM
                                    parameters))
                        AND (current_item_permanent_location_campus_name = (
                                SELECT
                                    items_permanent_campus_filter
                                FROM
                                    parameters)
                                OR '' = (
                                    SELECT
                                        items_permanent_campus_filter
                                    FROM
                                        parameters))
                            AND (current_item_permanent_location_institution_name = (
                                    SELECT
                                        items_permanent_institution_filter
                                    FROM
                                        parameters)
                                    OR '' = (
                                        SELECT
                                            items_permanent_institution_filter
                                        FROM
                                            parameters));

