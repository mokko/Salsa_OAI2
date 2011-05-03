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

                <lido:eventDate>
                    <!-- If an event date is described by a free text, it has to be mapped to a lido:displayDate element. -->
                    <lido:displayDate>
                        <xsl:value-of select="child::mpx:datierung"/>
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

                <!-- eventPlace -->
                <xsl:apply-templates select="mpx:geogr[@funktion ='Herkunft (Allgemein)']"/>

                <!--lido:eventMethod-->

                <!-- eventMaterialsTech -->
                <xsl:apply-templates select="mpx:materialTechnik"/>
            </lido:event>
        </lido:eventSet>
    </xsl:template>


    <xsl:template name="production-displayEvent">
        <lido:displayEvent xml:lang="de">
            <xsl:text>Herstellung</xsl:text>
            <xsl:if
                test="mpx:geogr[@funktion = 'Herkunft (Allgemein)' and (@bezeichnung !='Ethnie' or @bezeichnung != 'Kultur')] ">
                <xsl:text> in </xsl:text>
                <xsl:value-of
                    select="mpx:geogr[@bezeichnung !='Ethnie' or @bezeichnung != 'Kultur']"/>
            </xsl:if>
            <xsl:if test="mpx:personKörperschaftRef[@funktion ='Hersteller' ]">
                <xsl:text> durch </xsl:text>
                <xsl:value-of select="mpx:personKörperschaftRef[@funktion ='Hersteller' ]"/>
            </xsl:if>
        </lido:displayEvent>
    </xsl:template>


    <xsl:template match="mpx:personKörperschaftRef[@funktion = 'Hersteller']">
        <xsl:if test="@kueId">
            <lido:eventActor>
                <lido:actorInRole>
                    <xsl:call-template name="general-actor">
                        <xsl:with-param name="kueId" select="@kueId"/>
                    </xsl:call-template>
                </lido:actorInRole>
            </lido:eventActor>
        </xsl:if>
    </xsl:template>


    <xsl:template match="mpx:geogr[@funktion ='Herkunft (Allgemein)']">
        <lido:eventPlace>
            <lido:displayPlace>
                <xsl:value-of select="."/>
            </lido:displayPlace>
            <lido:place>
                <lido:namePlaceSet>
                    <lido:appellationValue>
                        <xsl:value-of select="."/>
                    </lido:appellationValue>
                </lido:namePlaceSet>
            </lido:place>
        </lido:eventPlace>
    </xsl:template>


    <xsl:template match="mpx:materialTechnik">
        <lido:eventMaterialsTech>
            <xsl:if test="mpx:materialTechnik[@art = 'Ausgabe']">
                <lido:displayMaterialsTech>
                    <xsl:value-of select="child::mpx:materialTechnik[@art = 'Ausgabe']"/>
                </lido:displayMaterialsTech>
            </xsl:if>
            <xsl:if test="mpx:materialTechnik[@art != 'Ausgabe']">
                <lido:materialsTech>
                    <lido:termMaterialsTech lido:type="material">
                        <lido:term><xsl:value-of select="child::mpx:materialTechnik[@art != 'Ausgabe']"/></lido:term>
                    </lido:termMaterialsTech>
                </lido:materialsTech>
            </xsl:if>
        </lido:eventMaterialsTech>
    </xsl:template>

</xsl:stylesheet>
