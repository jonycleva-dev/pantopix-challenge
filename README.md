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
- **Input**: N/A
- **Output**: Cleans the `output` directory.
- **Tool used**: Ant `delete` and `mkdir`.

### 2. `compile`
- **Input**: Java files in `src/`.
- **Output**: Compiled classes in `build/`.
- **Tool used**: Ant `javac`.

### 3. `convert-excel-to-xml`
- **Input**: `input/000_products_indent_noPrices.xlsx`
- **Output**: `output/000_products_indent_noPrices.xml`
- **Java Class**: `pantopix.exceltoxml.ExcelToXmlConverter`

### 4. `generate-html-preview`
- **Input**: `output/000_products_indent_noPrices.xml`
- **Output**: `output/000_products_indent_noPrices.html`
- **XSLT**: `src/transform_to_html.xslt`

### 5. `process-with-prices`
- **Input**:
    - `output/000_products_indent_noPrices.xml`
    - `input/priceData.xml`
- **Output**: `output/000_products_indent_withPrices.xml`
- **XSLT**: `src/020_addPrices_indent.xsl`

### 6. `generate-html-prices-preview`
- **Input**: `output/000_products_indent_withPrices.xml`
- **Output**: `output/000_products_indent_withPrices.html`
- **XSLT**: `src/transform_to_html.xslt`

### 7. `products-functional`
- **Input**: `output/000_products_indent_noPrices.xml`
- **Output**: `output/010_products_functional_noPrices.xml`
- **XSLT**: `src/010_convertToFunctionalXml.xsl`

### 8. `process-with-prices-functional`
- **Input**:
    - `output/010_products_functional_noPrices.xml`
    - `input/priceData.xml`
- **Output**: `output/020_products_functional_withPrices.xml`
- **XSLT**: `src/020_addPrices.xsl`

### 9. `generate-functional-csv`
- **Input**: `output/020_products_functional_withPrices.xml`
- **Output**: `output/030_products_parentId_withPrices.csv`
- **XSLT**: `src/030_convertToParentIdCsv.xsl`

### 10. `generate-functional-indent-csv`
- **Input**: `output/020_products_functional_withPrices.xml`
- **Output**: `output/040_products_indent_withPrices.csv`
- **XSLT**: `src/040_convertToParentIdOrIndentCsv.xsl`

### 11. `generate-csv`
- **Input**: `output/000_products_indent_withPrices.xml`
- **Output**: `output/040_products_indent_withPrices.csv`
- **XSLT**: `src/transform_to_csv.xslt`
