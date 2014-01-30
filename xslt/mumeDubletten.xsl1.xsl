<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="1.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- Versuch, solche alten und gefakten mume auszufiltern, die inzwischen 
		neuere Datensätze in M+ haben. Ich gehe davon aus, das multimediaobjektDateiname 
		in vielen Fällen eindeutig sein sollte. Insbesondere sollte ich gefakte mumes 
		herausfiltern, wenn ein nicht-gefaktes mume dasselbe Foto beschreibt. Dasselbe 
		Foto bestimme ich hier über den Dateinamen des Fotos. Ich brauche das in 
		xslt1, um es mit perl auf den Data provier anwenden zu können. -->

	<xsl:key name="dname" match="mpx:multimediaobjekt" use="mpx:multimediaDateiname" />


	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/">
		<xsl:copy>
			<xsl:apply-templates select="/mpx:museumPlusExport" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/mpx:museumPlusExport">
		<!-- mpx:multimediaobjekt[not(mpx:multimediaDateiname = preceding-sibling::mpx:multimediaobjekt/mpx:multimediaDateiname)] -->
		<xsl:copy>
			<xsl:for-each
				select="mpx:multimediaobjekt[not(mpx:multimediaDateiname = preceding-sibling::mpx:multimediaobjekt/mpx:multimediaDateiname)]">
				<xsl:sort select="mpx:multimediaDateiname" data-type="text" />
				<xsl:sort select="@quelle" />
				<xsl:variable name="dname" select="mpx:multimediaDateiname" />

				<xsl:message>
					<xsl:text>DEBUG:</xsl:text>
					<xsl:value-of
						select="count(//mpx:multimediaobjekt[
									mpx:multimediaDateiname= $dname and 
									@quelle='mpx-rif'])" />
					<xsl:text>&#xa;</xsl:text>
				</xsl:message>

				<xsl:choose>
					<xsl:when
						test="count(//mpx:multimediaobjekt[mpx:multimediaDateiname = $dname]) =1">
						<xsl:message>
							<xsl:text>only 1 mume with this vObj and dname&#xa;</xsl:text>
						</xsl:message>
						<xsl:apply-templates
							select="//mpx:multimediaobjekt[mpx:multimediaDateiname = $dname]" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>
							<xsl:text>1+ mume with this vObj and dname&#xa;</xsl:text>
						</xsl:message>
						<xsl:choose>
							<xsl:when
								test="count(//mpx:multimediaobjekt[
									mpx:multimediaDateiname= $dname and 
									@quelle='mpx-rif']) = 0">
								<xsl:message>
									<xsl:text>NONE of the mume with this vObj and dname are fake &#xa;</xsl:text>
								</xsl:message>
								<xsl:apply-templates
									select="//mpx:multimediaobjekt[mpx:multimediaDateiname = $dname]" />
							</xsl:when>
							<xsl:when
								test="count(//mpx:multimediaobjekt[mpx:multimediaDateiname= $dname]) -
									  count(//mpx:multimediaobjekt[mpx:multimediaDateiname= $dname and @quelle='mpx-rif']) 
									  = 0">
								<xsl:message>
									<xsl:text>ALL mume with this vObj and dname are fake &#xa;</xsl:text>
								</xsl:message>

								<xsl:apply-templates
									select="//mpx:multimediaobjekt[mpx:multimediaDateiname = $dname]" />
							</xsl:when>
							<xsl:when
								test="
							count(//mpx:multimediaobjekt[mpx:multimediaDateiname= $dname]) -
							count(//mpx:multimediaobjekt[mpx:multimediaDateiname= $dname and @quelle='mpx-rif']) 
							> 0">
								<xsl:message>
								<xsl:text>this group of mume with this vObj and dname is MIXED &#xa;</xsl:text>
								</xsl:message>
								<xsl:apply-templates select="//mpx:multimediaobjekt[mpx:multimediaDateiname= $dname and not(@quelle)]" />
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>


			<xsl:apply-templates select="/mpx:museumPlusExport/mpx:personKörperschaft" />
			<xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//mpx:multimediaobjekt">
		<xsl:message>
			<xsl:value-of select="mpx:multimediaDateiname" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="@quelle" />
			<xsl:text>&#xa;</xsl:text>
		</xsl:message>
		<xsl:copy-of select="." />

	</xsl:template>

</xsl:stylesheet>
