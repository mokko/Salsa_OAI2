<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="1.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- remove schemaLocation if any -->
	<xsl:template match="@xsi:schemaLocation" />

	<!-- identity -->

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="mpx:multimediaobjekt">
		<!-- Usually we need to copy all existing attributes -->
		<xsl:variable name="filepriority">
			<xsl:choose>
				<xsl:when test="contains (mpx:multimediaDateiname, '-A x')">
					<xsl:text>1</xsl:text>
				</xsl:when>
				<xsl:when test="contains (mpx:multimediaDateiname, '-B x')">
					<xsl:text>2</xsl:text>
				</xsl:when>
				<xsl:when test="contains (mpx:multimediaDateiname, '-C x')">
					<xsl:text>3</xsl:text>
				</xsl:when>
				<xsl:when test="contains (mpx:multimediaDateiname, '-D x')">
					<xsl:text>4</xsl:text>
				</xsl:when>
				<xsl:when test="contains (mpx:multimediaDateiname, '-E x')">
					<xsl:text>5</xsl:text>
				</xsl:when>
				<xsl:when test="contains (mpx:multimediaDateiname, '-F x')">
					<xsl:text>6</xsl:text>
				</xsl:when>
				<xsl:when test="contains (mpx:multimediaDateiname, '-G x')">
					<xsl:text>7</xsl:text>
				</xsl:when>
				<xsl:when test="contains (mpx:multimediaDateiname, '-H x')">
					<xsl:text>8</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>9</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element namespace="http://www.mpx.org/mpx" name="{name()}">
			<xsl:apply-templates
				select="@exportdatum|@mulId|@quelle|@freigabe|@priorität|@typ" />
			<!-- overwrite existing freigabe -->

			<xsl:choose>
				<!-- standardbild wird freigeben, ausser wenn Karteikarte '-KK' -->
				<xsl:when
					test="mpx:standardbild and not(contains (mpx:multimediaDateiname, ' -KK'))">
					<xsl:attribute name="freigabe">Web</xsl:attribute>
					<xsl:attribute name="priorität"><xsl:value-of
						select="$filepriority" /></xsl:attribute>
				</xsl:when>
				<!-- that should find only images whose dateiname ends with ' x' -->
				<xsl:when
					test="contains (mpx:multimediaDateiname, ' x') and substring-after(mpx:multimediaDateiname,
													' x') = ''">
					<!-- new case: no standardbild, but still a file with x as freigabe 
						marker at end of dateiname -->
					<xsl:attribute name="freigabe">Web</xsl:attribute>
					<xsl:attribute name="priorität"><xsl:value-of
						select="$filepriority+1" /></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="freigabe">intern</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>

			<!-- 
			RECONSTRUCT TYP ATTrIBUTE 
			Ich hatte Problem die Stelle (das Skript) zu nicht finden, wo die originalen Typ Informationen erzeugt werden. 
			Anscheinend: 
			Salsa_OAI2/xslt/mpxFix3/multimediaobjekt.xsl 
			See also 
			https://github.com/mokko/Salsa_OAI2/blob/master/xslt/mpx2lido/resourceSet.xsl 
				
			-->

			<xsl:if test="not(@typ)">
				<xsl:choose>
					<xsl:when
						test="mpx:multimediaErweiterung = 'jpg' or mpx:multimediaErweiterung = 'JPG'
														or mpx:multimediaErweiterung = 'tif' or mpx:multimediaErweiterung =
														'TIF' or mpx:multimediaErweiterung = 'tiff' or mpx:multimediaErweiterung
														= 'TIFF' or mpx:multimediaErweiterung = 'bmp' or mpx:multimediaErweiterung
														= 'BMP' ">
						<xsl:attribute name="typ">Bild</xsl:attribute>
					</xsl:when>
					<xsl:when
						test="mpx:multimediaErweiterung = 'mp3' or mpx:multimediaErweiterung = 'MP3'
														or mpx:multimediaErweiterung = 'wav' or mpx:multimediaErweiterung =
														'WAV'">
						<xsl:attribute name="typ">Audio</xsl:attribute>
					</xsl:when>
					<xsl:when
						test="mpx:multimediaErweiterung = 'mpeg' or mpx:multimediaErweiterung =
														'MPEG' or mpx:multimediaErweiterung = 'm4v' or mpx:multimediaErweiterung
														= 'mov' or mpx:multimediaErweiterung = 'avi' or mpx:multimediaErweiterung
														= 'mpg'">
						<xsl:attribute name="typ">Video</xsl:attribute>
					</xsl:when>
					<xsl:when
						test="mpx:multimediaErweiterung = 'doc' or mpx:multimediaErweiterung = 'DOC'
														or mpx:multimediaErweiterung = 'WPD' or mpx:multimediaErweiterung =
														'wpd' or mpx:multimediaErweiterung = 'pdf' or mpx:multimediaErweiterung
														= 'PDF'">
						<xsl:attribute name="typ">Text</xsl:attribute>
					</xsl:when>
					<xsl:when test="not(mpx:multimediaErweiterung)" />
					<xsl:otherwise>
						<xsl:message>
							<xsl:text>Unknown multimediaobjekt/@typ for objId:</xsl:text>
							<xsl:value-of select="mpx:verknüpftesObjekt" />
						</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<xsl:apply-templates select="child::*" />
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
