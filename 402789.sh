#!/bin/bash

##################################
# Script: Internet Sales Processing - lab10
# Author: Wiktoria Drozdz
# Creation Date: 2024-12-23
#
# Description:
# This script automates the process of downloading sales data from a ZIP file,
# validating the data, cleaning, processing, and loading it into a MySQL database.
# It also exports the database table to a CSV file and compresses the result.
#
# Changelog:
# - [2024-12-23] - Initial script creation with full process implementation
# - [2024-12-24] Added data validation improvements (SecretCode column)
#
# Note: To ensure the script functions correctly, the following must be installed: 
# - unzip
##################################

# Parameters
script_dir=$(dirname "$(realpath "$0")")
link="http://home.agh.edu.pl/~wsarlej/dyd/bdp2/materialy/cw10/InternetSales_new.zip"
output_path="$script_dir/output"
filepasswd="YmRwMmFnaA=="
index="402789"
sql_hostname="mysql.agh.edu.pl"
sql_userid="wdrozdz"
sql_passwd="dU5ycVp5eUp3RFAyNHdnZQ=="
sql_database="wdrozdz"
sql_port="3306"
TIMESTAMP=$(date +"%m%d%Y")
log_file="$output_path/${index}_raport_$TIMESTAMP.log"

mkdir -p "$output_path"
# Helper function for logging
log() {
    echo "$(date "+%Y%m%d%H%M%S") - $1" | tee -a "$log_file"
}

log "Starting script execution"

# Step 1: Download the file
log "Downloading file from $link"
wget "$link" -P "$output_path" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    log "Error during file download."
    exit 1
fi
log "File downloaded successfully."

# Step 2: Unzip the file
log "Unzipping the file"
unzip -P "$(echo -n $filepasswd | base64 -d)" "$output_path/InternetSales_new.zip" -d "$output_path" 
if [ $? -ne 0 ]; then
    log "Error during file extraction."
    exit 1
fi
log "File unzipped successfully."

# Step 3: Validate and clean data
input_file="$output_path/InternetSales_new.txt"
bad_file="$output_path/InternetSales_new.bad_$TIMESTAMP"
processed_file="$output_path/processed/${TIMESTAMP}_InternetSales_new.txt"

log "Validating and cleaning data"
mkdir -p "$output_path/processed"
echo "ProductKey|CurrencyAlternateKey|FirstName|LastName|OrderDateKey|OrderQuantity|UnitPrice|SecretCode\t" > "$processed_file"
rm -f "$bad_file"

row_index=0
while IFS='|' read -r -a columns; do
    if [ $row_index -eq 0 ]; then
        echo "$(IFS="|"; echo "${columns[*]}")" > "$processed_file"
        ((row_index++))
        continue
    fi

    if [ ${#columns[@]} -ne 6 ] || [ -z "${columns[4]}" ] || [ "${columns[4]}" -gt 100 ]; then
        echo "$(IFS="|"; echo "${columns[*]}")" >> "$bad_file"
        continue
    fi

    columns[7]=""

    if [[ $(IFS=','; set -- ${columns[2]}; echo $#) -ne 2 ]]; then
        echo "$(IFS="|"; echo "${columns[*]}")" >> "$bad_file"
        continue
    fi

    clipped_text=$(echo "${columns[2]}" | tr -d '"')
    IFS=',' read -r LastN FirstN <<< "$clipped_text"
    new_columns=("${columns[@]:0:2}" "$FirstN" "$LastN" "${columns[@]:3}")
    echo "$(IFS="|"; echo "${new_columns[*]}")" >> "$processed_file"
done < <(sed 's/\r$//' "$input_file" | awk '!seen[$0]++')

log "Data validation and cleaning completed."

# Step 4: Connect to MySQL and create table
log "Connecting to MySQL and creating table"
init_query="DROP TABLE IF EXISTS CUSTOMERS_$index;
CREATE TABLE CUSTOMERS_$index(
    ProductKey int,
    CurrencyAlternateKey varchar(3),
    FirstName varchar(255),
    LastName varchar(255),
    OrderDateKey int,
    OrderQuantity int,
    UnitPrice varchar(24),
    SecretCode varchar(10)
);"
mysql -h "$sql_hostname" -P "$sql_port" -u "$sql_userid" -p"$(echo -n $sql_passwd | base64 -d)" -D "$sql_database" -e "$init_query" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    log "Error during table creation."
    exit 1
fi
log "Table created successfully."

# Step 5: Insert data into the table
log "Inserting data into the table"
insert_data_query="LOAD DATA LOCAL INFILE '$processed_file'
INTO TABLE CUSTOMERS_$index
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;"
mysql --local-infile=1 -h "$sql_hostname" -P "$sql_port" -u "$sql_userid" -p"$(echo -n $sql_passwd | base64 -d)" -D "$sql_database" -e "$insert_data_query" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    log "Error during data insertion."
    exit 1
fi
log "Data inserted successfully."

# Step 6: Update 'SecretCode'
log "Updating 'SecretCode' column"
update_secret_code_query="UPDATE CUSTOMERS_$index SET SecretCode = SUBSTRING(MD5(RAND()), 1, 10);"
mysql -h "$sql_hostname" -P "$sql_port" -u "$sql_userid" -p"$(echo -n $sql_passwd | base64 -d)" -D "$sql_database" -e "$update_secret_code_query" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    log "Error during 'SecretCode' update."
    exit 1
fi
log "'SecretCode' column updated successfully."

# Step 7: Export table to CSV
log "Exporting table to CSV"
csv_file="$output_path/CUSTOMERS_${index}.csv"
mysql -h "$sql_hostname" -P "$sql_port" -u "$sql_userid" -p"$(echo -n $sql_passwd | base64 -d)" -D "$sql_database" -B -e "SELECT * FROM CUSTOMERS_$index;" > "$csv_file"
if [ $? -ne 0 ]; then
    log "Error during table export."
    exit 1
fi
log "Table exported to CSV successfully."

# Step 8: Compress the CSV file
log "Compressing the CSV file"
gzip "$csv_file"
if [ $? -ne 0 ]; then
    log "Error during file compression."
    exit 1
fi
log "CSV file compressed successfully."

# Cleanup
log "Cleaning up temporary files"
rm -f "$output_path/InternetSales_new.zip" "$input_file"
log "Script execution completed successfully."
