<xsl:stylesheet version="2.0"
                xmlns:my="http://pantopix.com/challengefunctions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="my xs">

    <!-- Parameters -->
    <xsl:param name="priceDataFile"/>

    <!-- Global variables -->
    <xsl:variable name="externalPriceData" select="document($priceDataFile)/priceData"/>
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

    <!-- Custom function to process the price -->
    <xsl:function name="my:processPrice" as="xs:string">
        <xsl:param name="inputNumber" as="xs:string"/>
        <xsl:variable name="normalizedNumber" select="translate($inputNumber, ',', '.')"/>
        <xsl:variable name="result" select="number($normalizedNumber) * 0.81"/>
        <xsl:value-of select="format-number($result, '0.#####')"/>
    </xsl:function>

    <xsl:template match="node[@type='article']">
        <xsl:variable name="fullId" select="normalize-space(prop[@key='articleNumber']/value)"/>
        <xsl:variable name="article" select="key('articleKey', substring-after($fullId, '-'), $externalPriceData)"/>
        <xsl:variable name="priceWoTax" select="my:processPrice($article/@price)"/>
        <xsl:copy>
            <!-- Copy all attributes and nodes of the row -->
            <xsl:apply-templates select="@*|node()"/>

            <xsl:if test="$article">
                <prop key="price">
                    <value><xsl:value-of select="concat($article/@price,' ',$article/@currency)"/></value>
                </prop>
                <prop key="priceWoTax">
                    <value><xsl:value-of select="concat( $priceWoTax, ' ',$article/@currency)"/></value>
                </prop>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
