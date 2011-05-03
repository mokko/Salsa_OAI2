<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <!-- 
        for the time being we focus on acquisition and creation

        suggested by MIMO D2.2 Guidelines: Acquisition, Creation, Finding, 
        Modification, Use
        
        Collecting, Designing, Destruction, Excavation, Exhibition, Loss, Move,
        Order, Part addition, Part removal, Performance, Planning, 
        Production, Provenance, Publication, Restoration, Transformation, 
        Type assignment, Type creation
    -->

    <xsl:import href="acquisition.xsl"/>
    <xsl:import href="production.xsl"/>

    <xsl:template name="eventWrap">
        <!-- TODO: PLAN FOR THE POSSIBILITY THAT I DON'T HAVE ENOUGH DATA FOR ANY EVENT!-->

        <lido:eventWrap>
            <!-- xsl:if test="s = s"-->
                <xsl:call-template name="production"/>
            <!--/xsl:if-->

            <!-- 
              it could be that acquisition event is only valid LIDO or MIMO if it has a date, 
              so I can just check whether date is there or not to trigger creation of 
              acquisition
            -->
            <xsl:if
                test="child::mpx:erwerbDatum|child::mpx:erwerbungVon|child::mpx:erwerbungsart|child::mpx:erwerbungsart">
                <xsl:call-template name="acquisition"/>
            </xsl:if>

        </lido:eventWrap>
    </xsl:template>

</xsl:stylesheet>
