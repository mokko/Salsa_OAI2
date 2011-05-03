<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="production">
        <lido:eventSet>
            <xsl:call-template name="production-displayEvent"/>
            <lido:event>
                <lido:eventType>
                    <lido:term>Production</lido:term>
                </lido:eventType>
                <lido:eventName>
                    <lido:appellationValue xml:lang="de">Herstellung</lido:appellationValue>
                </lido:eventName>

                <!-- 
                    TODO: 
                    -ensure that only cultures associated with Herstellung are named 
                    -to do so I need example data. At this point I am not sure there is any
                -->

                <!-- eventActor -->
                <xsl:apply-templates select="mpx:personKörperschaftRef[@funktion = 'Hersteller']"/>
                <xsl:call-template name="general-culture"/>

                <!-- eventDate-->
                <xsl:apply-templates select="mpx:datierung"/>

                <!-- eventPlace -->
                <xsl:apply-templates
                    select="mpx:geogrBezug [@funktion = 'Herkunft (Allgemein)'  and  @bezeichnung != 'Ethnie' ]"/>

                <!--lido:eventMethod-->

                <!-- eventMaterialsTech -->
                <xsl:call-template name="eventMaterialsTech"/>
            </lido:event>
        </lido:eventSet>
    </xsl:template>


    <xsl:template name="production-displayEvent">
        <lido:displayEvent xml:lang="de">
            <xsl:text>Herstellung</xsl:text>
            <!--
                mpx:geogr[@funktion = 'Herkunft (Allgemein)' and (@bezeichnung !='Ethnie' or @bezeichnung != 'Kultur')]
                what happens if there are several places?
            -->

            <xsl:variable name="productionPlace"
                select="mpx:geogrBezug [@funktion = 'Herkunft (Allgemein)' and  @bezeichnung != 'Ethnie' ]"/>

            <xsl:if test="$productionPlace">
                <xsl:text> am Ort </xsl:text>
                <xsl:value-of select="$productionPlace"/>
            </xsl:if>

            <xsl:if test="mpx:personKörperschaftRef[@funktion ='Hersteller' ]">
                <xsl:text> durch den/die Hersteller/Herstellerin </xsl:text>
                <xsl:value-of select="mpx:personKörperschaftRef[@funktion ='Hersteller' ]"/>
            </xsl:if>

            <xsl:variable name="culture"
                select="mpx:personKörperschaftRef[@funktion ='Ethnie' or @bezeichnung != 'Kultur' ]"/>
            <xsl:if test="$culture">
                <xsl:text> von der Ethnie/Kultur der </xsl:text>
                <xsl:value-of select="$culture"/>
            </xsl:if>
        </lido:displayEvent>
    </xsl:template>


    <xsl:template match="mpx:personKörperschaftRef[@funktion = 'Hersteller']">
        <lido:eventActor>
            <lido:actorInRole>
                <xsl:call-template name="general-actor">
                    <xsl:with-param name="kueId" select="@kueId"/>
                </xsl:call-template>
            </lido:actorInRole>
        </lido:eventActor>
    </xsl:template>


    <!-- Is this general? Might well be -->
    <xsl:template
        match="mpx:geogrBezug [@funktion = 'Herkunft (Allgemein)'  and  @bezeichnung != 'Ethnie' ]">
        <lido:eventPlace>
            <lido:displayPlace>
                <xsl:value-of select="."/>
            </lido:displayPlace>
            <lido:place>
                <lido:namePlaceSet>
                    <!-- I am pretty sure that it should be entered in German always -->
                    <lido:appellationValue xml:lang="de">
                        <xsl:value-of select="."/>
                    </lido:appellationValue>
                </lido:namePlaceSet>
            </lido:place>
        </lido:eventPlace>
    </xsl:template>


    <xsl:template name="eventMaterialsTech">
        <xsl:if test="mpx:materialTechnik">
            <lido:eventMaterialsTech>
                <lido:displayMaterialsTech>
                    <xsl:for-each select="mpx:materialTechnik">
                        <xsl:value-of select="."/>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="./@art"/>
                        <xsl:text>)</xsl:text>
                    </xsl:for-each>
                </lido:displayMaterialsTech>

                <!--lido:materialsTech>
                    <xsl:for-each select=".">
                        <lido:termMaterialsTech lido:type="material">
                            <lido:term xml:lang="de"><xsl:value-of select="parent"/></lido:term>
                        </lido:termMaterialsTech>
                    </xsl:for-each>
                </lido:materialsTech-->

            </lido:eventMaterialsTech>
        </xsl:if>
    </xsl:template>


    <!-- 
    should this become a general? it is not used in acquisition. At the moment 
    it is not used in collecting either 
    -->

    <xsl:template match="mpx:datierung">
        <lido:eventDate>
            <!-- If an event date is described by a free text, it has to be mapped to a lido:displayDate element. -->
            <lido:displayDate>
                <xsl:value-of select="."/>
            </lido:displayDate>
            <!-- 
                TODO: 
                Test if date is really a proper date and not freetext
                The dates format should be preferably YYYY[-MM[-DD]]: 
                at least the year should be specified. Nevertheless, other 
                formats are accepted (e.g 17??, 1850 ?, ca 1600, etc…).
                <lido:date>
                <lido:earliestDate>
                <xsl:value-of select="child::mpx:erwerbDatum"/>
                </lido:earliestDate>
                <lido:latestDate>
                <xsl:value-of select="child::mpx:erwerbDatum"/>
                </lido:latestDate>
                </lido:date>
            -->
        </lido:eventDate>
    </xsl:template>

</xsl:stylesheet>
