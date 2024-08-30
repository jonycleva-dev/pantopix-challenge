<xsl:stylesheet version="2.0"
                xmlns:my="http://pantopix.com/challengefunctions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="my xs">

    <!-- Parameters -->
    <xsl:param name="priceDataFile"/>

    <!-- Global variables -->
    <xsl:variable name="externalPriceData" select="document($priceDataFile)/priceData"/>
    <xsl:variable name="articleNumberColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[articleNumber]']/@iCol"/>
    <xsl:variable name="colCnt" select="/tableData/table/@colCnt"/>
    <xsl:key name="articleKey" match="article" use="@id"/>

    <xsl:output method="xml" indent="yes"/>

    <!-- Identity template to copy all elements and attributes -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Template for the root of the document -->
    <xsl:template match="/">
        <xsl:copy>
            <!-- Copy all content from the input file -->
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Template for the table -->
    <xsl:template match="table">
        <xsl:copy>
            <!-- Copy all attributes -->
            <xsl:apply-templates select="@*"/>

            <!-- update @colCnt -->
            <xsl:attribute name="colCnt">
                <xsl:value-of select="$colCnt + 2"/>
            </xsl:attribute>

            <!-- Copy all child nodes -->
            <xsl:apply-templates select="node()"/>

        </xsl:copy>
    </xsl:template>

    <!-- Template for the first row (header) to identify the '[id]' column -->
    <xsl:template match="row[1]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <!-- Adding price column -->
            <cell iCol="{$colCnt + 1}">
                <styleSettings textFormats="b"/>
                <value>[price]</value>
            </cell>
            <cell iCol="{$colCnt + 2}">
                <styleSettings textFormats="b"/>
                <value>[priceWoTax]</value>
            </cell>
        </xsl:copy>
    </xsl:template>

    <!-- Template for the remaining rows -->
    <xsl:template match="row[position() > 1]">
        <xsl:variable name="fullId" select="normalize-space(cell[@iCol = $articleNumberColumn]/value)"/>
        <xsl:variable name="article" select="key('articleKey', substring-after($fullId, '-'), $externalPriceData)"/>
        <xsl:variable name="priceWoTax" select="my:processPrice($article/@price)"/>

        <xsl:copy>
            <!-- Copy all attributes and nodes of the row -->
            <xsl:apply-templates select="@*|node()"/>

            <!-- Adding price value -->
            <cell iCol="{$colCnt + 1}">
                <xsl:if test="$article">
                    <value><xsl:value-of select="concat($article/@price,' ',$article/@currency)"/></value>
                </xsl:if>
            </cell>

            <!-- Adding priceWoTax value -->
            <cell iCol="{$colCnt + 2}">
                <xsl:if test="$article">
                    <value><xsl:value-of select="concat( $priceWoTax, ' ',$article/@currency)"/></value>
                </xsl:if>
            </cell>
        </xsl:copy>
    </xsl:template>

    <!-- Custom function to process the price -->
    <xsl:function name="my:processPrice" as="xs:string">
        <xsl:param name="inputNumber" as="xs:string"/>
        <xsl:variable name="normalizedNumber" select="translate($inputNumber, ',', '.')"/>
        <xsl:variable name="result" select="number($normalizedNumber) * 0.81"/>
        <xsl:value-of select="translate(format-number($result, '0.#####'), '.', ',')"/>
    </xsl:function>

</xsl:stylesheet>
