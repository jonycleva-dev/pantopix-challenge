<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text" encoding="UTF-8"/>

    <!-- Template to match the root and start processing -->
    <xsl:template match="/tableData/table">
        <!-- Process each row in the table -->
        <xsl:for-each select="row">
            <!-- Process each cell in the row -->
            <xsl:for-each select="cell">
                <!-- Output the value of the cell -->
                <xsl:value-of select="normalize-space(value)"/>
                <!-- Add a tab if this is not the last cell -->
                <xsl:if test="position() != last()">
                    <xsl:text>&#9;</xsl:text> <!-- Tab character -->
                </xsl:if>
            </xsl:for-each>
            <!-- Add a newline after each row -->
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>