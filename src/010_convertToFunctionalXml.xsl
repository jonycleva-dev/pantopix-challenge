<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <!-- Global variables to identify the columns that contain '[articleNumber]', '[id]', and '[article]' -->
    <xsl:variable name="articleNumberColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[articleNumber]']/@iCol"/>
    <xsl:variable name="idColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[id]']/@iCol"/>
    <xsl:variable name="articleColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[article]']/@iCol"/>

    <!-- Main template that matches the root element 'tableData' -->
    <xsl:template match="/tableData">
        <root data="products">
            <!-- Process rows that have a non-empty ID and do not contain a hyphen, i.e., top-level groups -->
            <xsl:apply-templates select="table/row[position() > 1][string(cell[@iCol=$idColumn]/value) and not(contains(cell[@iCol=$idColumn]/value, '-'))]" mode="processGroup"/>
        </root>
    </xsl:template>

    <!-- Template to process each row, grouping products by hierarchy -->
    <xsl:template match="row" mode="processGroup">
        <xsl:variable name="currentId" select="cell[@iCol=$idColumn]/value"/>
        <xsl:variable name="currentArticleNumber" select="cell[@iCol=$articleNumberColumn]/value"/>
        <xsl:variable name="nodeType">
            <xsl:choose>
                <xsl:when test="string($currentArticleNumber)">article</xsl:when>
                <xsl:otherwise>productGroup</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="$nodeType = 'article'">
                    <xsl:value-of select="cell[@iCol = $articleColumn]/value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="cell[string-length(value) > 0][1]" mode="findNameCell"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Create node -->
        <node type="{$nodeType}">
            <xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>

            <!-- Process additional properties -->
            <xsl:apply-templates select="cell[string-length(value) > 0 and not(@iCol = $idColumn or @iCol = $articleColumn)]" mode="getProp"/>

            <!-- Recursively process direct children that contain a hyphen immediately after the current ID -->
            <xsl:apply-templates select="following-sibling::row[
                starts-with(cell[@iCol = $idColumn]/value, concat($currentId, '-')) and
                not(contains(substring-after(cell[@iCol = $idColumn]/value, concat($currentId, '-')), '-'))
            ]" mode="processGroup"/>

            <!-- Check if the next row is an article and belongs to the current hierarchy -->
            <xsl:if test="string-length($currentId) > 0 and following-sibling::row[1][string-length(cell[@iCol = $articleNumberColumn]/value) > 0]">
                <!-- Normalize the article value from the next row -->
                <xsl:variable name="articleVale" select="normalize-space(following-sibling::row[1]/cell[@iCol = $articleNumberColumn]/value)" />

                <!-- Use replace to remove everything after the last hyphen, used for cases as DL-EH220-01,
                the prefix is different to parent id -->
                <xsl:variable name="articlePrefix" select="replace($articleVale, '-[^-]*$', '')"/>

                <!-- Process rows that start with the calculated article number prefix -->
                <xsl:apply-templates
                        select="following-sibling::row[(starts-with(cell[@iCol = $articleNumberColumn]/value,concat($articlePrefix,'-')))]" mode="processGroup"/>

            </xsl:if>
        </node>
    </xsl:template>

    <!-- Template to generate 'prop' elements -->
    <xsl:template match="cell" mode="getProp">
        <xsl:variable name="colName">
            <xsl:call-template name="getColName">
                <xsl:with-param name="iCol" select="@iCol"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="not(starts-with($colName, 'pgr'))">
            <prop key="{$colName}">
                <value>
                    <xsl:choose>
                        <!-- Special handling for string and number content -->
                        <xsl:when test="matches(value, '^\d+(\.\d+)?\s+\p{L}+$')">
                            <xsl:attribute name="unit"><xsl:value-of select="substring-after(value,' ')"/></xsl:attribute>
                            <xsl:value-of select="substring-before(value,' ')"/>
                        </xsl:when>
                        <!-- Default case: output the value directly -->
                        <xsl:otherwise>
                            <xsl:value-of select="value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </value>
            </prop>
        </xsl:if>
    </xsl:template>

    <!-- Template to find the first cell that can be used as a name -->
    <xsl:template match="cell" mode="findNameCell">
        <xsl:variable name="colName">
            <xsl:call-template name="getColName">
                <xsl:with-param name="iCol" select="@iCol"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="starts-with($colName, 'pgr')">
                <xsl:value-of select="value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="following-sibling::cell[string-length(value) > 0]" mode="findNameCell"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Template to extract the column name by processing the header row -->
    <xsl:template name="getColName">
        <xsl:param name="iCol"/>
        <xsl:value-of select="replace(replace(normalize-space(/tableData/table/row[1]/cell[@iCol = $iCol]/value), '\[', ''), '\]', '')"/>
    </xsl:template>
</xsl:stylesheet>
