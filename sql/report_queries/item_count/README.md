# Documentation for the RM item count query (UXPROD-2396)

## Contents
* [Status](https://github.com/folio-org/folio-analytics/tree/main/sql/report_queries/item_count#status)
* [Purpose](https://github.com/folio-org/folio-analytics/tree/main/sql/report_queries/item_count#purpose)
* [Filters](https://github.com/folio-org/folio-analytics/tree/main/sql/report_queries/item_count#filters)
* [Output](https://github.com/folio-org/folio-analytics/tree/main/sql/report_queries/item_count#output)
* [Requests not yet addressed](https://github.com/folio-org/folio-analytics/tree/main/sql/report_queries/item_count#requests-and-issues-not-yet-addressed)

## Purpose
To provide summary **item** and **piece** counts for **non-electronic** resources cataloged in the Inventory, by various filters.

<details>
  <summary>Click to read more!</summary>
  
  * The piece counts of item records are summed for the piece counts (assumes that all item records have peice counts, even if only one piece).
  * Location information is assigned by permanent location.
  * Modify this query to suit your local needs. This query was built to include many of the measures commonly used to get overall item and piece counts, such as those that record bibliographic format and library location information. Your library will not need all of these measures.  Some parameter filters are available.  We also try to spell out which assumptions are made (some of which individual institutions may need to adjust), and requests not yet addressed. 
  * Queries to count e-resources (whether tracked through the ERM or the Inventory) are available separately. Each reporter must know where their institution’s various resources are tracked and should find the needed reports as appropriate, adding together counts if needed, and avoiding any duplication if possible.
  * Note that it is generally assumed that if you need a holdings count as of a certain date, you take it on that date; while you may be able to use processing dates to exclude resources newly added after a certain date, you cannot get back titles that were withdrawn or transferred.
  * Local and national definitions can be updated from year to year; be sure to review for needed changes.
  </details>
  
  ## Filters
  
  #### Hardcoded filters (assumptions; in the where clause):
* Excludes: e-resources; suppressed instance records, and suppressed holdings records (when field becomes available).

<details>
  <summary>Click to read more!</summary>
  
  * Each holdings record has a permanent location.
  * Excludes suppressed instance records (instance discovery suppress value is “true”)
  * [When this field becomes available:] Excludes suppressed holdings records.
  * This query is intended to exclude e-resources. It excludes records with instance format names of “computer – online resource” or “ISNULL,”  and excludes records with holdings library names of “Online” or “ISNULL.” These values many need to be updated for your local needs.
  </details>
  
#### Parameter filters (at the top of the query):
 
* Through parameter filters, this SQL allows you to easily type in text to filter by: record status (including receipt status), resource format, statistical codes, language, dates, location, call number and holdings acquisition method.  

<details>
  <summary>Click to read more!</summary>
  
 * Record status:
   * Instance status:
     * Instance status name (you can use this parameter to include only those titles cataloged and made ready for use; for many institutions, this would be "cataloged" and "batchloaded"; note that if your institution sets an instance status of, e.g., "pda unpurchased" you can exclude unpurchased patron driven acquisitions items if needed) (query allows up to two selected simultaneously)
   * Holdings
     * Holdings receipt status (e.g., "not currently received," etc.)
   * Items
     * Item status filter (e.g., "available," "awaiting pikcup," "checked out," "declared lost," etc.)
* Resource format: (Reporters need to know how their institution's records format information locally; it may use one of more of these commonly used fields, but not all of them.)
  * Instance formats:
    * Instance types name (e.g., text, video, computer dataset, etc.)  (query allows up to three selected simultaneously)
    * Instance formats name (e.g., video – videocassette, unmediated – sheet, microform – microfilm roll, etc.)  (query allows up to three selected simultaneously)
    * Instance nature of content terms (e.g., autobiography, journal, newspaper, research report, etc.)
    * Inventory modes of issuance name (e.g., serial, integrating resource, single unit, unspecified, etc.)
    * (see also statistical codes)
  * Holdings formats:
    * Holdings types name (e.g., physical, electronic, serial, multi-part monograph, etc.)
    * (see also statistical codes)
  * Items formats:
    * Item discription of pieces
    * (see also statistical codes)
* Statistical codes
  * Instance statistical code name
  * Holdings statistical code name
  * Item statistical code (e.g., "books," "serials")
  * Item statistical code name (e.g., "Book, print (books)," "Serial, print (serials)"
* Language:
  * Languages (will include a value for each language used; if more than one language, the first is the primary language if there is one; use %% as wildcards; use, e.g., "%%eng%%" to get all titles that are fully or partially in english.)
* Dates:
  * Cataloged date (allows you to specify start and end date)
  * Item created date (allows you to specify start and end date)
  * item status date (allows you to specify start and end date)
  * Item chronology (may help you to identify items barcoded retrospectively, vs. currently)
* Location: (where housed) (institutions with a shared consortial database may need to filter with their institutional location information to verify ownership (i.e., presence of instance record alone not enough))
  * Holdings permanent location id (typically the lowest level in the location hierarchy -- the specific location within a library)
  * Holdings location name
  * Holdings campus name
  * Holdings institution name
* Call number:
  * Holdings call number types name (e.g., LC, NLM, Dewey Decimal, etc.)
  * Holdings call number (note that the call number field is a text string only (no breakouts); you may want to use truncation symbols as suggested in the filter to get at call number ranges)
* Holdings acquisition method (e.g., gift, deposit, membership, etc.)
  </details>
  
  #### Other fields you might want to filter on in results:
    * Instance previously held  (indicates the item was "previously held" in print in terms of, for example, HathiTrust digital access)
    * Super relation type name  (content within titles is sometimes analyzed (cataloged) as part of the larger, parent title; if you need to avoid including one level in your count in such cases, this and the following measure will allow you to exclude one or the other)
    * Sub relation type name (see immediately above)

## Output
Aggregation: This query provides counts grouped by:
* Item chronology; Item status name; Item material type id; Item material type name; Item statistical code id; Item statistical code; Item statistical code name;
* Holdings type id; Holdings type name; Holdings call number type id; Holdings call number type name; Holdings statistical code id; Holdings statistical code; Holdings statistical code name; Holdings receipt status;
* Location name;
* Instance type id; Instance type name; Mode of issuance id; Mode of issuance name; Instance format id; Instance format code; instance format name; Instance language (first); Instance statistical code id; Instance statistical code; Instance statistical code name; Instance nature of content id; Instance nature of content code; Instance nature of content name; Instance previously held; Instance super relationship type id; Instance super relationship type name; Instance sub relationship type id; Instance sub relationship type name

## Requests and issues not yet addressed

<details>
  <summary>Click to read more!</summary>
  
  See this page for additional information recorded by the Resource Management reporters: https://wiki.folio.org/x/OA8uAg 
  * How will we be able to exclude withdrawn items? (Jennifer will ask about this 12/20)
  * How will we be able to exclude any bound with items (if item records exist for these)?  See https://issues.folio.org/browse/UXPROD-2699?filter=1288508:46:36 for interesting Chicago discussion of item statuses as relates to boudn with (and HathiTrust ETAS restrictions). Also https://docs.google.com/document/d/1iWhEAxd3hvlvqmDgXmbJ2a3A_J2ahQHaMN2RKvDLvWI/edit .
  * Consider adding any code to break out call numbers?  (Jennnifer said the item call number is the effective call number.)
  * Should we add item material type source or is this material type source in general? (MARC, equipment, etc.) (generally not needed)
  * Should we add item material type category or is this material type category in general? Is it even implemented? In MM list. (MARC, equipment, etc.) (generally not needed)
  * Information tracked possibly through holdings records notes?: provenance; precious bindings, copy notes, dedications, inscriptions, left by decedents, etc. Use a filter with truncation. Which measures each institution uses to track this information could differ.
  * When fields available?:
    * When the holdings discover suppress field becomes available, add it to the WHERE hardcoded filters and update comment.
    * country of publication (source record)
    * date of publication (At this point in time, we are not bringing in the instance dataofpublication because it is not in standardized form; institutions may want to consider bringing it in if they set up parsing options to suit their needs. Will likely add date one and date two data from the source record when available (MARC  008 (places 7-10 for date 1, and 11-14 for date 2)).
    * geographic area code (source record)
    * is open access (source record?)
    * withdrawn in timeframe (instance suppressed with status update date in timeframe?)
    * transferred within the institution in a time period
    * has retention requirements / is an obligatory copy (have retention policy field on holdings?)
    * is government document (how this will be addressed by institutions can vary greatly; statistical code, location, source record (not yet available; e.g., MARC 008, 086 for federal US/Canadian docs))
    * acquired as part of a project
      </details>
