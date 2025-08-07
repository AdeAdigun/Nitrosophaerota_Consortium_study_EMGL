#!/bin/bash

xml_file="biosample_metadata.xml"
csv_file="biosample_metadata.csv"

# Write CSV header
echo -e "BioSample Accession\tSRA Accession\tCollection Date\tGeographic Location\tLatitude\tLongitude\tIsolation Source\tHost\tOxygen Relationship" > "$csv_file"

awk '
    BEGIN { RS="<BioSample "; FS="\n" }
    /accession=/ {
        match($0, /accession="([^"]+)"/, bs_acc)
        match($0, /<Id db="SRA">([^<]+)<\/Id>/, sra_acc)
        match($0, /<Attribute attribute_name="collection_date">([^<]+)<\/Attribute>/, collection_date)
        match($0, /<Attribute attribute_name="geo_loc_name">([^<]+)<\/Attribute>/, geo_loc)
        match($0, /<Attribute attribute_name="lat_lon">([^<]+)<\/Attribute>/, lat_lon)
        match($0, /<Attribute attribute_name="isolation_source">([^<]+)<\/Attribute>/, iso_source)
        match($0, /<Attribute attribute_name="host">([^<]+)<\/Attribute>/, host_attr)
        match($0, /<Attribute attribute_name="rel_to_oxygen">([^<]+)<\/Attribute>/, oxygen_rel)

        # Default values if missing
        bs = (bs_acc[1] ? bs_acc[1] : "NA")
        sra = (sra_acc[1] ? sra_acc[1] : "NA")
        date = (collection_date[1] ? collection_date[1] : "NA")
        location = (geo_loc[1] ? geo_loc[1] : "NA")
        iso = (iso_source[1] ? iso_source[1] : "NA")
        host = (host_attr[1] ? host_attr[1] : "NA")
        oxygen = (oxygen_rel[1] ? oxygen_rel[1] : "NA")

        # Extract latitude and longitude separately
        lat = lon = "NA"
        if (lat_lon[1] ~ /^[0-9]/) {
            split(lat_lon[1], coords, " ")
            lat = coords[1]  # Latitude value
            lon = coords[3]  # Longitude value

            # Convert coordinates to negative if necessary
            if (coords[2] == "S") lat = "-" lat
            if (coords[4] == "W") lon = "-" lon
        }

        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", bs, sra, date, location, lat, lon, iso, host, oxygen
    }
' "$xml_file" >> "$csv_file"

echo "Extraction complete! Data saved in $csv_file."
