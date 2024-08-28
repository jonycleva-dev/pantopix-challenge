<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <!-- Global variables to identify the columns that contain '[articleNumber]', '[id]', and '[article]' -->
    <xsl:variable name="articleNumberColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[articleNumber]']/@iCol"/>
    <xsl:variable name="idColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[id]']/@iCol"/>
    <xsl:variable name="articleColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[article]']/@iCol"/>

    <!-- Main template that matches the root element 'tableData' -->
    <xsl:template match="/tableData">
        <root data="products">
            <!-- Apply templates to process the second row in the table using 'groupProducts' mode -->
            <xsl:apply-templates select="table/row[2]" mode="groupProducts">
                <xsl:with-param name="level" select="1"/> <!-- Pass the initial level as 1 -->
            </xsl:apply-templates>
        </root>
    </xsl:template>

    <!-- Template to generate 'prop' elements for each cell, skipping those with 'pgr' prefix -->
    <xsl:template match="cell" mode="getProp">
        <xsl:variable name="colName">
            <xsl:call-template name="getColName">
                <xsl:with-param name="iCol" select="@iCol"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- Skip cells where the column name starts with 'pgr' -->
        <xsl:if test="not(starts-with($colName, 'pgr'))">
            <prop key="{$colName}">
                <value>
                    <xsl:choose>
                        <!-- Handle special case for 'voltage' to extract the unit and value separately -->
                        <xsl:when test="$colName = 'voltage'">
                            <xsl:attribute name="unit">
                                <xsl:value-of select="substring-after(value,' ')"/>
                            </xsl:attribute>
                            <xsl:value-of select="substring-before(value,' ')"/>
                        </xsl:when>
                        <!-- Default case: just output the value -->
                        <xsl:otherwise>
                            <xsl:value-of select="value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </value>
            </prop>
        </xsl:if>
    </xsl:template>

    <!-- Template to process each row in the table, grouping products by hierarchy -->
    <xsl:template match="row" mode="groupProducts">
        <xsl:param name="level"/> <!-- Parameter to track the current hierarchy level -->
        <xsl:variable name="currentId" select="cell[@iCol=$idColumn]/value"/>
        <xsl:variable name="currentArticleNumber" select="cell[@iCol=$articleNumberColumn]/value"/>

        <!-- Determine if the current row represents an 'article' or 'productGroup' -->
        <xsl:variable name="nodeType">
            <xsl:choose>
                <xsl:when test="string-length($currentArticleNumber) > 0">article</xsl:when>
                <xsl:otherwise>productGroup</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <node type="{$nodeType}">
            <!-- Determine the 'name' attribute based on the node type -->
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="$nodeType = 'article'">
                        <xsl:value-of select="cell[@iCol = $articleColumn]/value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="cell[string-length(value) > 0][1]" mode="findNameCell"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!-- Include 'id' attribute if it exists -->
            <xsl:if test="string-length($currentId) > 0">
                <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
            </xsl:if>

            <!-- Apply templates to process additional properties in cells -->
            <xsl:apply-templates select="cell[string-length(value) > 0 and not(@iCol = $idColumn or @iCol = $articleColumn)]" mode="getProp"/>

            <!-- Recursively process following rows that belong to the current group -->
            <xsl:apply-templates select="following-sibling::row[(starts-with(cell[@iCol = $idColumn]/value,concat($currentId,'-')))
            and not(contains(substring-after(cell[@iCol = $idColumn]/value,concat($currentId,'-')),'-'))]" mode="groupProducts">
                <xsl:with-param name="level" select="$level + 1"/>
            </xsl:apply-templates>

            <!-- Check if the next row is an article and belongs to the current hierarchy -->
            <xsl:if test="string-length($currentId) > 0 and following-sibling::row[1][string-length(cell[@iCol = $articleNumberColumn]/value) > 0]">
                <!-- Normalize the article value from the next row -->
                <xsl:variable name="articleVale" select="normalize-space(following-sibling::row[1]/cell[@iCol = $articleNumberColumn]/value)" />

                <!-- Call the template to extract the article prefix before the last separator -->
                <xsl:variable name="articlePrefix">
                    <xsl:call-template name="before-last-separator">
                        <xsl:with-param name="input" select="$articleVale" />
                        <xsl:with-param name="separator" select="'-'" />
                    </xsl:call-template>
                </xsl:variable>

                <!-- Process rows that start with the calculated article prefix -->
                <xsl:apply-templates
                        select="following-sibling::row[(starts-with(cell[@iCol = $articleNumberColumn]/value,concat($articlePrefix,'-')))]" mode="groupProducts">
                    <xsl:with-param name="level" select="$level + 1"/>
                </xsl:apply-templates>
            </xsl:if>
        </node>

        <!-- If this is the top level, continue processing the next ungrouped row -->
        <xsl:if test="$level = 1">
            <xsl:apply-templates select="following-sibling::row[string-length(cell[@iCol = $idColumn]/value) > 0 and not(starts-with(cell[@iCol = $idColumn]/value,concat($currentId,'-')))][1]" mode="groupProducts">
                <xsl:with-param name="level" select="$level"/>
            </xsl:apply-templates>
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
                <xsl:apply-templates select="following-sibling::cell[string-length(value) > 0]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Template to extract the column name by processing the header row -->
    <xsl:template name="getColName">
        <xsl:param name="iCol"/>
        <xsl:value-of select="substring-after(substring-before(
            normalize-space(/tableData/table/row[1]/cell[@iCol = $iCol]/value),']'), '[')"/>
    </xsl:template>

    <!-- Recursive template to find the part of the string before the last separator -->
    <xsl:template name="before-last-separator">
        <xsl:param name="input" />
        <xsl:param name="separator" select="'-'" />

        <xsl:choose>
            <!-- Recursively find the last separator -->
            <xsl:when test="contains($input, $separator)">
                <!-- Call the template with the remaining string after the first separator -->
                <xsl:variable name="remaining" select="substring-after($input, $separator)" />
                <xsl:variable name="beforeLastSeparator">
                    <xsl:call-template name="before-last-separator">
                        <xsl:with-param name="input" select="$remaining" />
                        <xsl:with-param name="separator" select="$separator" />
                    </xsl:call-template>
                </xsl:variable>

                <!-- If the remaining string doesn't contain the separator, return the original input -->
                <xsl:choose>
                    <xsl:when test="$beforeLastSeparator != ''">
                        <xsl:value-of select="concat(substring-before($input, $separator), $separator, $beforeLastSeparator)" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before($input, $separator)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
