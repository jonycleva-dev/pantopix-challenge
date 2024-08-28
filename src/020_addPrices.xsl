<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Global variable to get all article elements -->
    <xsl:key name="articleKey" match="priceData/node/article" use="@id"/>

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

    <xsl:template match="node[@type='article']">
        <xsl:variable name="fullId" select="normalize-space(prop[@key='articleNumber']/value)"/>
        <xsl:variable name="article" select="key('articleKey', substring-after($fullId, '-'))"/>
        <xsl:variable name="normalizedPrice" select="translate($article/@price, ',', '.')"/>
        <xsl:variable name="originalPrice" select="number($normalizedPrice)"/>
        <xsl:variable name="priceWoTax" select="format-number($originalPrice * 0.81, '#0.00')"/>
        <xsl:copy>
            <!-- Copy all attributes and nodes of the row -->
            <xsl:apply-templates select="@*|node()"/>

            <xsl:if test="$article">
                <prop key="price">
                    <value><xsl:value-of select="concat($originalPrice,' ',$article/@currency)"/></value>
                </prop>
                <prop key="priceWoTax">
                    <value><xsl:value-of select="concat( $priceWoTax, ' ',$article/@currency)"/></value>
                </prop>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- removing prideData -->
    <xsl:template match="priceData"/>

</xsl:stylesheet>
