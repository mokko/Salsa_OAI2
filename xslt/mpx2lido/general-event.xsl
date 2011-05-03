<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <!-- 
        lido:actor potentially reappears in all events. We want the same code 
        only once, so we include it here and refer to it as 'general-' 
    -->

    <xsl:template name="general-actor">
        <xsl:param name="kueId"/>

        <xsl:element name="lido:actor">
            <!-- lido:actor/@type -->
            <xsl:call-template name="general-type">
                <xsl:with-param name="kueId" select="$kueId"/>
            </xsl:call-template>

            <lido:actorID lido:type="local">
                <xsl:value-of select="$kueId"/>
            </lido:actorID>

            <lido:nameActorSet>
                <lido:appellationValue>
                    <xsl:value-of select="."/>
                </lido:appellationValue>
            </lido:nameActorSet>

            <xsl:apply-templates
                select="/mpx:museumPlusExport/mpx:personKörperschaft[@kueId = $kueId]/mpx:nationalität">
                <xsl:with-param name="kueId" select="$kueId"/>
            </xsl:apply-templates>

            <xsl:call-template name="general-vitalDatesActor">
                <xsl:with-param name="kueId" select="$kueId"/>
            </xsl:call-template>

            <!-- 
                genderActor
                Last time I checked, Geschlecht was not exportable from M+ (a bug in M+)
            -->
        </xsl:element>
    </xsl:template>


    <xsl:template name="general-vitalDatesActor">
        <xsl:param name="kueId"/>
        <lido:vitalDatesActor>
            <!-- 
                TODO 
                -mpx:datierung can have date ranges which need to be split up reliably
                -mpx:datierung can have all kinds of crap, I need ISO dates
                -an example. Where are life dates mentioned?
            -->
            <lido:earliestDate lido:encodinganalog="mpx:personKörperschaft/mpx:datierung">
                <xsl:value-of
                    select="/mpx:museumPlusExport/mpx:personKörperschaft[@kueId = $kueId]/mpx:datierung"
                />
            </lido:earliestDate>

            <lido:latestDate>
                <xsl:value-of
                    select="/mpx:museumPlusExport/mpx:personKörperschaft[@kueId = $kueId]/mpx:datierung"
                />
            </lido:latestDate>
        </lido:vitalDatesActor>
    </xsl:template>


    <xsl:template match="/mpx:museumPlusExport/mpx:personKörperschaft/mpx:nationalität">
        <xsl:param name="kueId"/>
        <xsl:if
            test="/mpx:museumPlusExport/mpx:personKörperschaft[@kueId = $kueId]/mpx:nationalität">
            <lido:nationalityActor>
                <lido:term>
            <xsl:value-of select="."/>
        </lido:term>
            </lido:nationalityActor>
        </xsl:if>
    </xsl:template>


    <xsl:template name="general-type">
        <xsl:param name="kueId"/>

        <!--xsl:message>
            <xsl:value-of select="$kueId"/>
        </xsl:message-->

        <xsl:attribute name="lido:type">
            <!-- 
                a vocabulary mapping in XSLT; not sure this is the way to go; 
                alternative could be replacement from an xml dictionary 
            -->
            <xsl:choose>
                <xsl:when
                    test="/mpx:museumPlusExport/mpx:personKörperschaft[@kueId = $kueId]/mpx:typ = 'Person'">
                    <xsl:text>person</xsl:text>
                </xsl:when>
                <xsl:when
                    test="/mpx:museumPlusExport/mpx:personKörperschaft[@kueId = $kueId]/mpx:typ = 'Körperschaft'">
                    <xsl:text>institution</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template name="general-culture">
        <xsl:if test="child::geogrBezug[@art='Ethnie' or @art='Kultur']">
            <lido:culture>
                <xsl:value-of select="child::mpx:geogrBezug[@art='Ethnie' or @art='Kultur']"/>
            </lido:culture>
        </xsl:if>
    </xsl:template>
    

</xsl:stylesheet>
