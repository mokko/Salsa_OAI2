<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mpx="http://www.mpx.org/mpx"
    exclude-result-prefixes="mpx">
    <!-- 
    Warum Freigabe? Wir wollen nicht automatisch alle beschriebenen Multimediaobjekte 
    auch nach MIMO bewegen, sondern auswählen können, was bei MIMO landet.
    
    Konkreter: Der Workflow hängt an zwei Stellen von der Freigabe ab
    a) MPX2LIDO: In mpx werden alle existierenden Multimediaobjekte angezeigt. Auf Wunsch von Paris werden in
        in LIDO nur solche Resourcen angezeigt, die auch freigegeben/hochgeladen wurden. 
    b) MIMO-resmvr.pl:        
    
    Der Faker mpx-rif hat seinen eigenen Freigabe Mechanismus. D.h. dieses Skript muss die existierende 
    Freigabe in der Regel beibehalten. 
    
    Dieses Script müsste dann im Wesentlichen die Freigabe für nicht gefakte multimediaobjekte erledigen. 
    Wie kann ich die nicht gefakten d.h. direkt aus M+ exportierten Multimediaobjekte wie diejenigen des 
    Borisexport erkennen? 
    
    Ich könnte in die gefakten ein Attribut quelle="mpx-rif" schreiben.
    
    
    
    Strategie: es wir alles
    Karteikarten kriegen keine Freigabe.
    
    Freigegeben sind diejenigen, 
    -->

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- remove schemaLocation if any-->
     <xsl:template match="@xsi:schemaLocation"/>

    <!-- identity-->
    <xsl:template match="node()|@*">

        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mpx:multimediaobjekt">
        <!-- 
            Usually we need to copy all existing attributes
        -->
        <xsl:element namespace="http://www.mpx.org/mpx" name="{name()}">
            <xsl:apply-templates select="@exportdatum|@mulId|@quelle|@freigabe|@priorität"/>

            <!-- if @freigabe exists copy it, if not work on it-->
            <xsl:choose>
                <xsl:when test="@freigabe">
                    <xsl:apply-templates select="@freigabe"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="mpx:standardbild">
                            <xsl:attribute name="freigabe">Web</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="freigabe">intern</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>

            <!-- 
                if priorität exists copy it. 
                if not and standardbild exists set priorität=10
            -->
            <xsl:choose>
                <xsl:when test="@priorität">
                    <xsl:apply-templates select="@priorität"/>
                </xsl:when>
                <xsl:otherwise>
                        <xsl:if test="mpx:standardbild">
                            <xsl:attribute name="priorität">10</xsl:attribute>
                        </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="child::*"/>
        </xsl:element>
  </xsl:template>
</xsl:stylesheet>
