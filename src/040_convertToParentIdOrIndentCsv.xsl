<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">

    <!-- Global variables -->
    <xsl:variable name="allProps" as="xs:string*" select="distinct-values(//prop/@key)" />
    <xsl:variable name="maxLevel" as="xs:integer" select="max(for $n in //node return count($n/ancestor::node)) + 1" />

    <xsl:output method="text" encoding="UTF-8" />

    <xsl:template match="/root">
        <!-- header dynamic levels -->
        <xsl:for-each select="1 to $maxLevel">
            <xsl:value-of select="concat('[pgr',.,']&#9;')"/>
        </xsl:for-each>
        <xsl:text>[id]&#9;parentId]</xsl:text>
        <xsl:for-each select="$allProps">
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="concat('[',.,']')"/>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>

        <xsl:apply-templates select="//node"/>
    </xsl:template>

    <xsl:template match="node">
        <xsl:variable name="level" select="count(ancestor::node) + 1" />

        <!-- empty columns before -->
        <xsl:for-each select="1 to $level - 1">
            <xsl:text>&#9;</xsl:text>
        </xsl:for-each>

        <xsl:value-of select="@name"/>

        <!-- empty columns after -->
        <xsl:for-each select="$level + 1 to $maxLevel">
            <xsl:text>&#9;</xsl:text>
        </xsl:for-each>

        <!-- id -->
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="@id"/>

        <!-- parentId -->
        <xsl:text>&#9;</xsl:text>
        <xsl:choose>
            <xsl:when test="parent::node">
                <xsl:value-of select="../@id"/>
            </xsl:when>
            <xsl:otherwise>root</xsl:otherwise>
        </xsl:choose>


        <xsl:variable name="currentNode" select="current()"/>

        <!-- props values -->
        <xsl:for-each select="$allProps">
            <xsl:variable name="currentProp" select="."/>
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="$currentNode/prop[@key=$currentProp]/value" />
            <xsl:if test="$currentNode/prop[@key=$currentProp]/value/@unit">
                <xsl:value-of select="concat(' ',$currentNode/prop[@key=$currentProp]/value/@unit)" />
            </xsl:if>
        </xsl:for-each>

        <xsl:text>&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
