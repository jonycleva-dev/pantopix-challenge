<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:output method="html" indent="yes"/>

    <!-- Declare the parameter for the filename -->
    <xsl:param name="fileName" />

    <xsl:template match="/">
        <html>
            <head>
                <title>Table Data Preview</title>
            </head>
            <body>
                <!-- Display only the file name from the full path -->
                <h1><xsl:value-of select="$fileName"/></h1>
                <p id="top">Tables Overview</p>
                <ol>
                    <li>
                        <a href="#d2e2">
                            <xsl:value-of select="/tableData/table/@name"/>
                        </a>
                        (<xsl:value-of select="/tableData/table/@colCnt"/> cols,
                        <xsl:value-of select="/tableData/table/@rowCnt"/> rows)
                    </li>
                </ol>
                <br/>
                <p id="d2e2">
                    Tab. 1: <b><xsl:value-of select="/tableData/table/@name"/></b>
                    (<xsl:value-of select="/tableData/table/@colCnt"/> cols,
                    <xsl:value-of select="/tableData/table/@rowCnt"/> rows)<br/>
                    <a href="#top">[top]</a>
                </p>
                <table border="1">
                    <!-- Header Row with idx and column numbers -->
                    <tr>
                        <td style="color: gray;">idx</td>
                        <!-- Generate the column numbers using XSLT 2.0 sequence -->
                        <xsl:for-each select="1 to /tableData/table/@colCnt">
                            <td style="color: gray;">
                                <xsl:value-of select="."/>
                            </td>
                        </xsl:for-each>
                    </tr>

                    <!-- Rows of the table -->
                    <xsl:for-each select="/tableData/table/row">
                        <tr>
                            <td style="color: gray;">
                                <xsl:value-of select="@iRow"/>
                            </td>
                            <xsl:for-each select="cell">
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
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </table>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>