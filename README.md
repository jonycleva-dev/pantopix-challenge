# Pantopix Challenge

This project is designed to process an Excel file containing product data, transform it into various formats such as XML, HTML, and CSV, and enrich the data by adding price information.

## Project Structure

- **src/**: Contains the source XSLT files and Java classes.
- **input/**: Directory for input files, including the initial Excel file and price data.
- **output/**: Directory where the generated XML, HTML, and CSV files are stored.
- **lib/**: Contains the necessary libraries (JAR files) used in the project.
- **build/**: Directory where compiled Java classes are stored.

## Build Targets

### 1. `clean`
Cleans the output directory by deleting all existing files and recreating the directory.

### 2. `compile`
Compiles the Java source code located in the `src` directory and places the compiled classes into the `build` directory.

### 3. `convert-excel-to-xml`
Converts the Excel file (`000_products_indent_noPrices.xlsx`) located in the `input` directory to an XML file. The output XML file is saved in the `output` directory.

### 4. `generate-html-preview`
Generates an HTML preview of the XML file without prices. This is done using the `transform_to_html.xslt` stylesheet.

### 5. `process-with-prices`
Adds price information from the `priceData.xml` file to the XML data and creates a new XML file (`000_products_indent_withPrices.xml`) with the enriched data.

### 6. `generate-html-prices-preview`
Generates an HTML preview of the XML file that includes the prices, using the `transform_to_html.xslt` stylesheet.

### 7. `products-functional`
Transforms the initial XML data into a functional format using the `010_convertToFunctionalXml.xsl` stylesheet.

### 8. `process-with-prices-functional`
Adds price information to the functional XML format and generates an enriched XML file (`020_products_functional_withPrices.xml`).

### 9. `generate-csv`
Generates a CSV file from the XML data that includes prices. The CSV file is created using the `transform_to_csv.xslt` stylesheet and saved as `040_products_indent_withPrices.csv` in the `output` directory.

