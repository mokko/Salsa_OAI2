<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="erwerbung">
        <lido:eventSet>
            <lido:displayEvent>Erwerbung durch <xsl:value-of
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
            </lido:displayEvent>
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
                <lido:eventID>
                    <xsl:choose>
                        <xsl:when test="child::mpx:erwerbNr">
                            <xsl:value-of select="child::mpx:erwerbNr"/>
                        </xsl:when>
                        <xsl:otherwise>not known</xsl:otherwise>
                    </xsl:choose>
                </lido:eventID>
                <lido:eventType>Acquisition</lido:eventType>
                <lido:eventName>
                    <lido:appellationValue xml:lang="de">Erwerb</lido:appellationValue>
                    <!-- dislay = free text -->
                    <lido:displayActorInRole>Erwerb von <xsl:value-of
                            select="child::mpx:erwerbungVon"/> (Veräußerer)</lido:displayActorInRole>
                    <lido:actor lido:type="person">
                        <lido:nameActorSet>
                            <lido:appellationValue>
                                <xsl:value-of select="child::mpx:erwerbungVon"/>
                            </lido:appellationValue>
                            <!-- TODO: ensure that only cultures associated with Erwerb are named 
                            <xsl:if test="child::geogrBezug[@art='Ethnie' or @art='Kultur']">
                                <lido:culture>
                                    <xsl:value-of select="child::mpx:geogrBezug"/>
                                </lido:culture>
                                </xsl:if>-->
                            <!--lido:actorID/-->
                        </lido:nameActorSet>
                    </lido:actor>
                    <lido:eventDate>
                        <!-- If an event date is described by a free text, it has to be mapped to a lido:displayDate element. -->
                        <lido:displayDate>
                            <xsl:value-of select="child::mpx:erwerbDatum"/>
                        </lido:displayDate>
                        <!-- 
                            TODO: Test if date is really a proper date and not freetext
                            The dates format should be preferably YYYY[-MM[-DD]]: 
                            at least the year should be specified. Nevertheless, other 
                            formats are accepted (e.g 17??, 1850 ?, ca 1600, etc…).
                        -->
                        <lido:date>
                            <lido:earliestDate>
                                <xsl:value-of select="child::mpx:erwerbDatum"/>
                            </lido:earliestDate>
                            <lido:latestDate>
                                <xsl:value-of select="child::mpx:erwerbDatum"/>
                            </lido:latestDate>
                        </lido:date>
                    </lido:eventDate>
                </lido:eventName>
            </lido:event>
        </lido:eventSet>
    </xsl:template>
</xsl:stylesheet>
