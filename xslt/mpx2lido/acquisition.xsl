<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="acquisition">
        <lido:eventSet>
            <xsl:call-template name="acquisition-displayEvent"/>
            <lido:event>
                <!-- eventID-->
                <xsl:apply-templates select="mpx:erwerbNr"/>

                <lido:eventType>
                    <lido:term>Acquisition</lido:term>
                </lido:eventType>

                <lido:eventName>
                    <lido:appellationValue xml:lang="de">Erwerb</lido:appellationValue>
                </lido:eventName>

                <!-- eventActor-->
                <xsl:apply-templates select="mpx:erwerbungVon"/>
                <xsl:apply-templates select="mpx:personKörperschaftRef[@funktion = 'Veräußerer']"/>

                <!-- eventDate -->
                <xsl:apply-templates select="mpx:erwerbDatum"/>
                <!-- isn't general-vitalDatesActor missing here? -->
            </lido:event>
        </lido:eventSet>
    </xsl:template>


    <xsl:template name="acquisition-displayEvent">
        <lido:displayEvent xml:lang="de">
            <xsl:text>Erwerbung durch </xsl:text>
            <xsl:value-of select="mpx:verwaltendeInstitution"/>
            <xsl:text> (oder dessen Vorgänger) </xsl:text>
            <xsl:if test="child::mpx:erwerbDatum">
                <xsl:value-of select="mpx:erwerbDatum"/>
            </xsl:if>
            <xsl:if
                test="mpx:erwerbungVon|mpx:personKörperschaftRef[@funktion = 'Veräußerer']">
                <xsl:text> vom Veräußerer </xsl:text>
                <xsl:value-of select="child::mpx:erwerbungVon"/>
                <xsl:value-of select="child::mpx:personKörperschaftRef[@funktion = 'Veräußerer']"/>
            </xsl:if>
            <xsl:if test="mpx:erwerbungsart">
                <xsl:text> mittels </xsl:text>
                <xsl:value-of select="mpx:erwerbungsart"/>
            </xsl:if>
            <xsl:if test="mpx:erwerbNr">
                <xsl:text> als </xsl:text>
                <xsl:value-of select="mpx:erwerbNr"/>
            </xsl:if>
        </lido:displayEvent>
    </xsl:template>


    <xsl:template match="mpx:erwerbNr">
        <lido:eventID lido:type="local" lido:encodinganalog="mpx:erwerbNr">
            <xsl:value-of select="."/>
        </lido:eventID>
    </xsl:template>


    <xsl:template match="mpx:erwerbungVon">
        <lido:eventActor>
            <lido:displayActorInRole>
                <xsl:value-of select="."/>
                <xsl:text>, Veräußerer</xsl:text>
            </lido:displayActorInRole>
            <lido:actorInRole>
                <!-- 
                    TODO:
                    MPX Data does not allow me to determine if person or not, while MIMO/LIDO probably doesn't 
                    allow to leave this undecided 
                -->
                <lido:actor lido:type="unspecified">
                    <lido:nameActorSet>
                        <lido:appellationValue>
                            <xsl:value-of select="."/>
                        </lido:appellationValue>
                    </lido:nameActorSet>
                </lido:actor>
            </lido:actorInRole>
        </lido:eventActor>
    </xsl:template>


    <xsl:template match="mpx:personKörperschaftRef[@funktion = 'Veräußerer']">
        <lido:eventActor>
            <lido:displayActorInRole><xsl:value-of select="."/>, Veräußerer</lido:displayActorInRole>
            <lido:actorInRole>
                <xsl:call-template name="general-actor">
                    <xsl:with-param name="kueId" select="@id"/>
                </xsl:call-template>
            </lido:actorInRole>
        </lido:eventActor>
    </xsl:template>


    <xsl:template match="mpx:erwerbDatum">
        <lido:eventDate>
            <!-- If an event date is described by a free text, it has to be mapped to a lido:displayDate element. -->
            <lido:displayDate>
                <xsl:value-of select="."/>
            </lido:displayDate>
            <!-- 
                TODO: Test if date is really a proper date and not freetext
                The dates format should be preferably YYYY[-MM[-DD]]: 
                at least the year should be specified. Nevertheless, other 
                formats are accepted (e.g 17??, 1850 ?, ca 1600, etc…).
            -->
            <lido:date>
                <lido:earliestDate>
                    <xsl:value-of select="."/>
                </lido:earliestDate>
                <lido:latestDate>
                    <xsl:value-of select="."/>
                </lido:latestDate>
            </lido:date>
        </lido:eventDate>
    </xsl:template>

</xsl:stylesheet>
