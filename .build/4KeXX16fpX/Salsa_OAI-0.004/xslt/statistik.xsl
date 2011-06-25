<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.mpx.org/mpx"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mpx="http://www.mpx.org/mpx"
    exclude-result-prefixes="mpx">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <html>
            <header>
                <title>mpx Statisktik</title>
            </header>
            <body>
                <h1>mpx Statisktik</h1>
                <h2>Anzahl wichtiger Datensätze</h2>
                <p>Sammlungsobjekte: <xsl:value-of
                        select="count (/mpx:museumPlusExport/mpx:sammlungsobjekt)"/><br/>
                    <ul>
                        <li>Sammlungsobjekte ohne perKörRef - davon ohne personKörperschaftRef (soll
                            0): <xsl:value-of
                                select="count (/mpx:museumPlusExport/mpx:sammlungsobjekt[not (mpx:personKörperschaftRef)])"
                            /></li>
                        <li>Sammlungsobjekte ohne identifizierte PerKör - davon ohne
                            personKörperschaftRef/@id: <xsl:value-of
                                select="count (/mpx:museumPlusExport/mpx:sammlungsobjekt[not (mpx:personKörperschaftRef/@id)])"
                            /></li>
                        <li>Sammlungsobjekte ohne Multimedia Datensatz: ?</li>
                    </ul> Multimediaobjekte <xsl:value-of
                        select="count (/mpx:museumPlusExport/mpx:multimediaobjekt)"/><br/>
                    <ul>
                        <li>davon ohne verknüpftes Objekt: <xsl:value-of
                                select="count (/mpx:museumPlusExport/mpx:multimediaobjekt[not (mpx:verknüpftesObjekt)])"
                            />
                        </li>
                    </ul> PersonenKörperschaften <xsl:value-of
                        select="count (/mpx:museumPlusExport/mpx:personKörperschaft)"/><br/>
                </p>
                <p>Sammlungsobjekte ohne verlinktesObjekt (objId)</p>
                <ul>
                    <xsl:for-each
                        select="/mpx:museumPlusExport/mpx:sammlungsobjekt/@objId[not (. = /mpx:museumPlusExport/mpx:multimediaobjekt/mpx:verknüpftesObjekt)]">
                        <xsl:variable name="objId" select="."/>
                        <xsl:message>
                            <xsl:value-of select="$objId"/>
                        </xsl:message>
                        <li>
                            <xsl:value-of select="$objId"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
