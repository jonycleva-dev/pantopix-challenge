<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <!-- Global variable to identify the column that contains '[articleNumber]' and '[id]' and '[article]' -->
    <xsl:variable name="articleNumberColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[articleNumber]']/@iCol"/>
    <xsl:variable name="idColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[id]']/@iCol"/>
    <xsl:variable name="articleColumn" select="/tableData/table/row[1]/cell[normalize-space(value) = '[article]']/@iCol"/>

    <!-- Main template -->
    <xsl:template match="/tableData">
        <root data="products">
            <xsl:apply-templates select="table/row[2]" mode="groupProducts">
                <xsl:with-param name="level" select="1"/>
            </xsl:apply-templates>
        </root>
    </xsl:template>

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
                        <xsl:when test="$colName = 'voltage'">
                            <xsl:attribute name="unit">
                                <xsl:value-of select="substring-after(value,' ')"/>
                            </xsl:attribute>
                            <xsl:value-of select="substring-before(value,' ')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </value>
            </prop>
        </xsl:if>
    </xsl:template>

    <!-- Template to process each row -->
    <xsl:template match="row" mode="groupProducts">
        <xsl:param name="level"/>
        <xsl:variable name="currentId" select="cell[@iCol=$idColumn]/value"/>
        <xsl:variable name="currentArticleNumber" select="cell[@iCol=$articleNumberColumn]/value"/>

        <xsl:variable name="nodeType">
            <xsl:choose>
                <xsl:when test="string-length($currentArticleNumber) > 0">article</xsl:when>
                <xsl:otherwise>productGroup</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <node type="{$nodeType}">
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
            <xsl:if test="string-length($currentId) > 0">
                <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="cell[string-length(value) > 0 and not(@iCol = $idColumn or @iCol = $articleColumn)]" mode="getProp"/>

            <xsl:apply-templates select="following-sibling::row[(starts-with(cell[@iCol = $idColumn]/value,concat($currentId,'-')))
            and not(contains(substring-after(cell[@iCol = $idColumn]/value,concat($currentId,'-')),'-'))]" mode="groupProducts">
                <xsl:with-param name="level" select="$level + 1"/>
            </xsl:apply-templates>

            <xsl:if test="string-length($currentId) > 0 and following-sibling::row[1][string-length(cell[@iCol = $articleNumberColumn]/value) > 0]">


                <!-- Original string -->
                <xsl:variable name="articleVale" select="normalize-space(following-sibling::row[1]/cell[@iCol = $articleNumberColumn]/value)" />

                <!-- Call the recursive template -->
                <xsl:variable name="articlePrefix">
                    <xsl:call-template name="before-last-separator">
                        <xsl:with-param name="input" select="$articleVale" />
                        <xsl:with-param name="separator" select="'-'" />
                    </xsl:call-template>
                </xsl:variable>

                <xsl:apply-templates
                    select="following-sibling::row[(starts-with(cell[@iCol = $articleNumberColumn]/value,concat($articlePrefix,'-')))]" mode="groupProducts">
                    <xsl:with-param name="level" select="$level + 1"/>
                </xsl:apply-templates>
            </xsl:if>

        </node>
        <xsl:if test="$level = 1">
            <xsl:apply-templates select="following-sibling::row[string-length(cell[@iCol = $idColumn]/value) > 0 and not(starts-with(cell[@iCol = $idColumn]/value,concat($currentId,'-')))][1]" mode="groupProducts">
                <xsl:with-param name="level" select="$level"/>
            </xsl:apply-templates>
        </xsl:if>

    </xsl:template>

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
