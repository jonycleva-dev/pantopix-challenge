package pantopix.exceltoxml;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.usermodel.FontUnderline;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

/**
 * This class converts an Excel (.xlsx) file into an XML structure according to the specified format.
 * It reads the Excel file, processes its content, and writes the corresponding XML file.
 */
public class ExcelToXmlConverter {

    /**
     * Main method to run the conversion process.
     * @param args Command-line arguments: args[0] = input Excel file path, args[1] = output XML file path, args[2] = table name.
     * @throws IOException If there is an error reading the Excel file.
     * @throws ParserConfigurationException If there is an error setting up the XML document builder.
     */
    public static void main(String[] args) throws IOException, ParserConfigurationException {
        // Ensure that the correct number of arguments are provided
        if (args.length != 3) {
            System.out.println("Usage: ExcelToXmlConverter <input_excel_file> <output_xml_file> <table_name>");
            return;
        }

        // Assign input and output file paths and table name from arguments
        String inputFilePath = args[0];
        String outputFilePath = args[1];
        String tableName = args[2];

        // Load the Excel workbook and select the first sheet
        Workbook workbook = WorkbookFactory.create(new File(inputFilePath));
        Sheet sheet = workbook.getSheetAt(0);

        // Create a new XML document
        Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
        Element rootElement = doc.createElement("tableData");  // Root element <tableData>
        doc.appendChild(rootElement);

        // Create the table element with attributes, including the dynamic table name
        Element tableElement = doc.createElement("table");
        tableElement.setAttribute("name", tableName);
        tableElement.setAttribute("rowCnt", String.valueOf(sheet.getLastRowNum() + 1));
        tableElement.setAttribute("colCnt", String.valueOf(sheet.getRow(0).getLastCellNum()));
        rootElement.appendChild(tableElement);

        // Iterate over each row in the Excel sheet
        for (Row row : sheet) {
            Element rowElement = doc.createElement("row");  // Each row becomes a <row> element
            rowElement.setAttribute("iRow", String.valueOf(row.getRowNum() + 1));
            tableElement.appendChild(rowElement);

            // Iterate over each cell in the row
            for (Cell cell : row) {
                Element cellElement = doc.createElement("cell");
                cellElement.setAttribute("iCol", String.valueOf(cell.getColumnIndex() + 1));
                rowElement.appendChild(cellElement);

                // Check for cell formatting and apply it to the XML
                CellStyle cellStyle = cell.getCellStyle();
                Font font = workbook.getFontAt(cellStyle.getFontIndexAsInt());
                Element styleSettings = doc.createElement("styleSettings");
                StringBuilder textFormats = new StringBuilder();

                // Check for bold
                if (font.getBold()) {
                    textFormats.append("b");
                }

                // Check for italic
                if (font.getItalic()) {
                    textFormats.append("i");
                }

                // Check for underline
                if (font.getUnderline() != FontUnderline.NONE.getByteValue()) {
                    textFormats.append("u");
                }

                // If there is any style, add it to the cell element
                if (textFormats.length() > 0) {
                    styleSettings.setAttribute("textFormats", textFormats.toString());
                    cellElement.appendChild(styleSettings);
                }

                // Get the cell value and only create <value> element if it is not empty
                String cellValue = cell.toString().trim();
                if (!cellValue.isEmpty()) {
                    Element valueElement = doc.createElement("value");
                    valueElement.appendChild(doc.createTextNode(cellValue));
                    cellElement.appendChild(valueElement);
                }
            }
        }

        // Write the XML content to the output file
        try (FileOutputStream output = new FileOutputStream(outputFilePath)) {
            Transformer transformer = TransformerFactory.newInstance().newTransformer();
            transformer.transform(new DOMSource(doc), new StreamResult(output));
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Close the workbook to free up resources
        workbook.close();
    }
}