<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <!-- Parameter to receive the path of the price data file -->
    <xsl:param name="priceDataFile"/>

    <!-- Load the price data file -->
    <xsl:variable name="priceData" select="document($priceDataFile)/priceData"/>

    <xsl:output method="xml" indent="yes"/>

    <!-- Identity template to copy all elements and attributes -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Template for the root of the document -->
    <xsl:template match="/*">
        <xsl:copy>
            <!-- Copy all content from the input file -->
            <xsl:apply-templates select="@*|node()"/>
            <!-- Add the content from priceData.xml at the end -->
            <xsl:copy-of select="$priceData"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
