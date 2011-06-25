<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="collecting">
        <lido:eventSet>
            <xsl:call-template name="collecting-displayEvent"/>
            <lido:event>
                <lido:eventType>
                    <lido:term>Collecting</lido:term>
                </lido:eventType>
                <lido:eventName>
                    <lido:appellationValue xml:lang="de">Sammeln</lido:appellationValue>
                </lido:eventName>

                <!-- eventActor -->                
                <xsl:apply-templates select="mpx:personKörperschaftRef[@funktion = 'Sammler']"/>
                
                <!-- culture, eventDate, eventPlace ... -->
            </lido:event>
        </lido:eventSet>
    </xsl:template>


    <xsl:template name="collecting-displayEvent">
        <lido:displayEvent xml:lang="de">
            <xsl:text>Gesammelt von </xsl:text>
            <xsl:value-of select="mpx:personKörperschaftRef[@funktion = 'Sammler']"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="mpx:datierung"/>
        </lido:displayEvent>
    </xsl:template>


    <xsl:template match="mpx:personKörperschaftRef[@funktion = 'Sammler']">
         <!-- without kueId this doesn't make sense -->
            <lido:eventActor>
                <lido:actorInRole>
                    <xsl:call-template name="general-actor">
                        <xsl:with-param name="kueId" select="@id"/>
                    </xsl:call-template>
                </lido:actorInRole>
            </lido:eventActor>
    </xsl:template>
    
</xsl:stylesheet>
