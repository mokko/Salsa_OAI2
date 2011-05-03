<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="production">
        <lido:eventSet>
            <!--  TODO
                durch <xsl:value-of
                select="child::mpx:verwaltendeInstitution"/> (oder dessen Vorgänger) <xsl:if
                test="child::mpx:erwerbDatum">
                <xsl:value-of select="child::mpx:erwerbDatum"/>
                </xsl:if>
                <xsl:if test="child::mpx:erwerbungVon"> von <xsl:value-of
                select="child::mpx:erwerbungVon"/></xsl:if>
                <xsl:if test="child::mpx:erwerbungsart"> mittels <xsl:value-of
                select="child::mpx:erwerbungsart"/></xsl:if><xsl:if
                test="child::mpx:erwerbungsart"> als <xsl:value-of select="child::mpx:erwerbNr"
                /></xsl:if> 
            -->
            <lido:displayEvent>Herstellung</lido:displayEvent>
            <lido:event>
                <!-- 
                    I don't know how to generate a unique ID for this event. It would
                    be easy to make a unique value for this object, but it would be difficult to
                    be unique for the whole SPK data. How can I ensure that this value will be
                    created here again the next time. Maybe something along the lines of
                    spk:objId:Acquisition 
                -->
                <!-- 
                    TODO: NOT ensured that there is ALWAYS an erwerbNr 
                -->
                <lido:eventType>
                    <lido:term>Production</lido:term>
                </lido:eventType>
                <lido:eventName>
                    <lido:appellationValue xml:lang="de">Herstellung</lido:appellationValue>
                </lido:eventName>
                <!-- TODO: ensure that only cultures associated with Herstellung are named -->

                <lido:eventActor>
                    <lido:actorInRole>
                        <lido:actor>
                            <lido:nameActorSet>
                                <lido:appellationValue xml:lang="de">[TODO:Name des Herstellers]</lido:appellationValue>
                                <!--lido:actorID/-->
                            </lido:nameActorSet>
                        </lido:actor>
                    </lido:actorInRole>
                </lido:eventActor>
                <xsl:if test="child::geogrBezug[@art='Ethnie' or @art='Kultur']">
                    <lido:culture>
                        <xsl:value-of select="child::mpx:geogrBezug"/>
                    </lido:culture>
                </xsl:if>

                <lido:eventDate>
                    <!-- If an event date is described by a free text, it has to be mapped to a lido:displayDate element. -->
                    <lido:displayDate>
                        <xsl:value-of select="child::mpx:datierung"/>
                    </lido:displayDate>
                    <!-- 
                            TODO: Test if date is really a proper date and not freetext
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
                <!--lido:eventPlace/>
                    <lido:eventMethod/-->
                <xsl:apply-templates select="mpx:materialTechnik"/>
            </lido:event>
        </lido:eventSet>
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
