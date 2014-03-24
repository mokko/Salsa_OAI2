<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:lido="http://www.lido-schema.org" xmlns:mpx="http://www.mpx.org/mpx"
	exclude-result-prefixes="mpx">

	<!-- Old version assumed that there is NOT always a @priorität attribute 
		for each multimediaobjekt that is web accessible. Today we shouldn't have 
		this case anymore. in mpx: it is perfectly possible that one object has one 
		video, one image, one sound example. Each of them might be characterized 
		with priorität=1 in mpx. MIMO insists that in lido -that only images can 
		have preferred status -only ever one preferred status per sammlungsobjekt -->


	<xsl:template name="resourceID">
		<!-- VARIOUS VARIABLES -->

		<!-- filename: determine resource path -->
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:variable name="lcExt"
			select="translate(mpx:multimediaErweiterung,$uppercase, $smallcase)" />
		<!-- file conversions done by resmvr.pl this is not good programming, this 
			is quick and dirty. If there are more conversions, better move this process 
			somewhere else. In mpx-rif, I guess -->
		<xsl:variable name="filename">
			<xsl:value-of select="@mulId" />
			<xsl:text>.</xsl:text>
			<xsl:choose>
				<xsl:when test="$lcExt = 'tif' or $lcExt = 'tiff'">
					<xsl:text>jpg</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$lcExt" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- objId -->
		<xsl:variable name="objId" select="../mpx:sammlungsobjekt/@objId" />

		<!-- minPriority. Can minPriority be empty? I think so. What happens then? 
		../mpx:multimediaobjekt[mpx:verknüpftesObjekt = $objId and @typ ='Bild']/@priorität
		-->
		<xsl:variable name="minPriority">
			<xsl:for-each select="../mpx:multimediaobjekt[mpx:verknüpftesObjekt = $objId and @typ ='Bild']/@priorität">
				<xsl:sort select="." />
				<xsl:if test="position() = 1">
					<xsl:value-of select="." />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<!-- NOW WRITE THE XML -->

		<xsl:element name="lido:resourceID">
			<!-- xsl:message>
				<xsl:value-of select="$filename" />
				<xsl:text> </xsl:text>

				<xsl:text>minPriority: </xsl:text>
				<xsl:value-of select="$minPriority" />
				<xsl:text> </xsl:text>

				<xsl:text>Priority: </xsl:text>
				<xsl:value-of select="@priorität" />
				<xsl:text> </xsl:text>

			</xsl:message -->
			<xsl:if
				test="@priorität = $minPriority and @typ ='Bild'">

				<xsl:attribute name="lido:pref">preferred</xsl:attribute>
			</xsl:if>

			<xsl:attribute name="lido:type">local</xsl:attribute>
			<xsl:value-of select="$filename" />
		</xsl:element>
	</xsl:template>


	<!-- NOTE: this does not work anymore with big xml file. It will look for 
		all multimediaobjekte regardless of they belong to this sammlungsobjekt We 
		have to add [mpx:verknüpftesObjekt=$objId] $min: the lowest @priorität of 
		any image attached slow, but universal: ../mpx:multimediaobjekt[mpx:verknüpftesObjekt=$objId]/@priorität[../@typ 
		='Bild'] a little faster, but works only inside data provider ../mpx:multimediaobjekt/@priorität[../@typ 
		='Bild'] anything that wants the preferred attribute has to be a image, web-accessible 
		and linked -->

</xsl:stylesheet>