<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html" indent="yes"/>

    <xsl:strip-space elements="*"/>

    <!-- Parameters -->
    <xsl:param name="fileName" />

    <!-- Global variables -->
    <xsl:variable name="colCnt" select="/tableData/table/@colCnt"/>
    <xsl:variable name="rowCnt" select="/tableData/table/@rowCnt"/>
    <xsl:variable name="tableName" select="/tableData/table/@name"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Table Data Preview</title>
            </head>
            <body>
                <h1><xsl:value-of select="$fileName"/></h1>
                <p id="top">Tables Overview</p>
                <ol>
                    <li>
                        <a href="#d2e2">
                            <xsl:value-of select="$tableName"/>
                        </a>
                        (<xsl:value-of select="$colCnt"/> cols,
                        <xsl:value-of select="$rowCnt"/> rows)
                    </li>
                </ol>
                <br/>
                <p id="d2e2">
                    Tab. 1: <b><xsl:value-of select="$tableName"/></b>
                    (<xsl:value-of select="$colCnt"/> cols,
                    <xsl:value-of select="$rowCnt"/> rows)<br/>
                    <a href="#top">[top]</a>
                </p>
                <!-- Apply templates to generate the table -->
                <xsl:apply-templates select="/tableData/table"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="table">
        <table border="1">
            <!-- Header Row with idx and column numbers -->
            <tr>
                <td style="color: gray;">idx</td>
                <!-- Generate the column numbers -->
                <xsl:for-each select="1 to $colCnt">
                    <td style="color: gray;">
                        <xsl:value-of select="."/>
                    </td>
                </xsl:for-each>
            </tr>

            <xsl:apply-templates select="row"/>
        </table>
    </xsl:template>

    <xsl:template match="row">
        <tr>
            <td style="color: gray;">
                <xsl:value-of select="@iRow"/>
            </td>
            <xsl:apply-templates select="cell"/>
        </tr>
    </xsl:template>

    <xsl:template match="cell">
        <td>
            <xsl:choose>
                <xsl:when test="styleSettings/@textFormats">
                    <b><xsl:value-of select="value"/></b>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="value"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>

</xsl:stylesheet>
