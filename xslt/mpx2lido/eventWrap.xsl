<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <!-- 
        suggested by MIMO D2.2 Guidelines: Acquisition, Creation, Finding, 
        Modification, Use. Others: Collecting, Designing, Destruction, 
        Excavation, Exhibition, Loss, Move, Order, Part addition, Part removal,
        Performance, Planning, Production, Provenance, Publication, 
        Restoration, Transformation, Type assignment, Type creation
    -->

    <!--  import EVENT TYPES and stuff common to all events -->
    <xsl:import href="acquisition.xsl"/>
    <xsl:import href="collecting.xsl"/>
    <xsl:import href="production.xsl"/>
    <xsl:import href="general-event.xsl"/>

    <xsl:template name="eventWrap">

        <!-- 
            TODO
            it could be that acquisition event is only valid LIDO or MIMO if it has a date, 
            so I can just check whether date is there or not to trigger creation of 
            acquisition
        -->

        <!-- 
            CONDITIONS under which we have one or more events
            it is possible that we don't have enough info for any of the events 
        -->
        <xsl:if
            test="
            mpx:materialTechnik or
            mpx:geogrBezug or 
            mpx:personKörperschaftRef[@funktion = 'Hersteller'] or
            mpx:personKörperschaftRef[@funktion = 'Sammler'] or
            mpx:erwerbDatum  or 
            mpx:erwerbungVon or 
            mpx:erwerbungsart">

            <lido:eventWrap>
                <xsl:if test="mpx:materialTechnik|mpx:geogrBezug | mpx:personKörperschaftRef[@funktion = 'Hersteller']">
                    <xsl:call-template name="production"/>
                </xsl:if>

                <xsl:if test="mpx:personKörperschaftRef[@funktion = 'Sammler']">
                    <xsl:call-template name="collecting"/>
                </xsl:if>

                <xsl:if
                    test="mpx:erwerbDatum or mpx:erwerbungVon or mpx:erwerbungsart">
                    <xsl:call-template name="acquisition"/>
                </xsl:if>
            </lido:eventWrap>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
