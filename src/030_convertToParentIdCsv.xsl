<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">

    <!-- Variable to store all unique props -->
    <xsl:variable name="allProps" as="xs:string*" select="distinct-values(//prop/@key)" />

    <xsl:output method="text" encoding="UTF-8" />

    <xsl:template match="/root">
        <!-- Create the CSV header -->
        <xsl:text>[id]&#9;[name]&#9;[parentId]</xsl:text>
        <xsl:for-each select="$allProps">
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="concat('[',.,']')"/>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>

        <xsl:apply-templates select="//node"/>
    </xsl:template>

    <xsl:template match="node">
        <!-- Output the id column -->
        <xsl:value-of select="@id"/>
        <xsl:text>&#9;</xsl:text>
        <!-- Output the name column -->
        <xsl:value-of select="@name"/>
        <xsl:text>&#9;</xsl:text>
        <!-- Output the parentId column -->
        <xsl:choose>
            <xsl:when test="parent::node">
                <xsl:value-of select="../@id"/>
            </xsl:when>
            <xsl:otherwise>root</xsl:otherwise>
        </xsl:choose>

        <xsl:variable name="currentNode" select="current()"/>

        <!-- Iterate over all Props to generate corresponding columns -->
        <xsl:for-each select="$allProps">
            <xsl:variable name="currentProp" select="."/>
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="$currentNode/prop[@key=$currentProp]/value" />
        </xsl:for-each>

        <xsl:text>&#10;</xsl:text> <!-- New line after each node row -->
    </xsl:template>
</xsl:stylesheet>
