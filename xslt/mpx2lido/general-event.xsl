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
            <xsl:call-template name="general-actorType">
                <xsl:with-param name="kueId" select="$kueId"/>
            </xsl:call-template>

            <xsl:if test="$kueId">
                <lido:actorID lido:type="local">
                    <xsl:value-of select="$kueId"/>
                </lido:actorID>
            </xsl:if>

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
        <xsl:if test="$kueId">

            <xsl:variable name="lebensdaten"
                select="/mpx:museumPlusExport/mpx:personKörperschaft[@kueId = $kueId]/mpx:datierung[@art = 'Lebensdaten'] "/>

            <!--  
                TODO 
                -mpx:datierung can have date ranges which need to be split up reliably
                -mpx:datierung can have all kinds of crap, I need ISO dates
                -an example. Where are life dates mentioned?
                
                Lebensdaten
                Lebensdaten if contains exactly one dash split at dash and take
                left side as earliest and right side as latest, but only of left and
                right side consists of numbers, dots and slashes. This is still 
                pretty dirty.
                
                TODO: resulting string is not ISO 8601

            -->

            <xsl:if
                test="string-length($lebensdaten) - string-length(translate($lebensdaten, '-', '')) = 1">
                <xsl:variable name="earliest"
                    select="normalize-space(substring-before($lebensdaten,'-'))"/>
                <xsl:variable name="latest"
                    select="normalize-space(substring-after($lebensdaten,'-'))"/>
                <xsl:if
                    test="
                    $earliest != '' and 
                    $latest !='' and
                    translate($earliest,'0123456789./','') = '' and                      
                    translate($earliest,'0123456789./','') = ''
                ">
                    <lido:vitalDatesActor>
                        <lido:earliestDate
                            lido:encodinganalog="mpx:personKörperschaft/mpx:datierung[@art = 'Lebensdaten']">
                            <xsl:value-of select="$earliest"/>
                        </lido:earliestDate>

                        <lido:latestDate
                            lido:encodinganalog="mpx:personKörperschaft/mpx:datierung[@art = 'Lebensdaten']">
                            <xsl:value-of select="$latest"/>
                        </lido:latestDate>
                    </lido:vitalDatesActor>
                </xsl:if>
            </xsl:if>
        </xsl:if>
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


    <xsl:template name="general-actorType">
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
                    <xsl:text>corporation</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <!-- 
                        it seems that LIDO forces me to have a type and that Thierry forces me to chose from his list (person|corporation|family), 
                        so I prefer to have potentially wrong data than no data at all  
                    -->
                    <xsl:text>person</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="general-culture">
        <xsl:for-each select="mpx:geogrBezug[@bezeichnung='Ethnie' or @bezeichnung='Kultur']">
            <lido:culture>
                <lido:term>
                    <xsl:value-of select="."/>
                </lido:term>
            </lido:culture>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
