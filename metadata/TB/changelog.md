# Change log for TB
To see additional details of the metadata objects mentioned below, refer to the metadata reference documentation of the version in question.

## Aggregate

### Version 1.1.1
* Included user group `UKWx4jJcrKt` "TB data capture", which has data capture rights on all data shareable objects (only in the complete package)
* Changed publicaccess sharing to metadata view and data view.
* Removed dashboard `o2Wg6pXAN6X` "TB2.Notifications (rates)", and associated chart `gTcOAYjw4CQ`, pivot table `HCmjOlNONzQ` and map `z4FMNqKG4gl`.
* Updated dashboard layout for use with the new dashboard app (from DHIS 2.29 and above)
* Updated periods in favourites, including data up to and including Q2 2019 (where relevant)
* Minor layout changes to pivot tables `hQ1ksBSIpQr` and `n6ZXdAl1sfD`
* Updated map favourite names
	* Using the built-in translation support for French names rather than having both English and French names.
	* Renamed maps `Eq9lKUQOykM` and `HFi8Oy2fFdJ` from TBm_3.8_... to TBm_3.7_...
	* Renamed maps `b6VznqkP4Hc` and `oA74TkHOKnX` to "TBc_3.5_Ratio of TB cases aged 0-4:5-14 year olds in new and relapse" and "TBc_3.5_Ratio of TB cases aged 0-4:5-14 year olds in new and relapse (annual)"
* Fixed chart `TfeoSE7Ha8F`, changing data dimension from category option group set "Sex" to "Sex (with unknown)"
* Fixed denominator of indicator `whkj4kr4ghD`, should be `#{hKTgk1mG2qn} + #{PdhQ1JCS2ij} + #{M6JHtLJJ34t} + #{KZ7rMA7BqcQ} + #{l4TyT04yP8f} + #{NYxehRdsQx3} +#{QNFhsj0fOxK} + #{Nv1RGi4eI7F} + #{NJaeD9Xia7x} + #{KhCB35MHs9A}`
* Changed description of indicator `p18w24U0caC`
* Changed name, shortName, code and description of indicator `VLtzufVWnHc`
* Fixed 3 validation rules with incorrrect formulas:
	* `bDjCyRMtkHO` - New pulmonary smear-positive
	* `VhVCSKuqraP` - New pulmonary smear-negative/smear-unknown/smear not done
	* `hZveAwRhLRh` - New extrapulmonary cases
* Renamed chart `Fw0CsA5Dpvf` (from "TBc_4.3c_Treatment outcomes for DR-TB (%) (annual)" to "TBc_5.5_Treatment outcomes for DR-TB (%) (annual)), and added it to dashboard `xJXvUOEhnE9` ("TB5. DR-TB (annual)").

### Version 1.1.0
* Added three validation rules for the TB/HIV section of the "TB treatment outcomes" data set:
	* `hXd2GANq20y` - "TB/HIV testing (by time of outcome)"
	* `zANh0v8Sbr1` - "HIV-positive TB patients on co-trimoxazole preventive therapy (CPT) (by time of outcome)"
	* `EG3H3WrJnKe` - "HIV-positive TB patients on antoretroviral therapy (ART) (by time of outcome)"
* Fixed three validation rules:
	* `puOMC36U2ad` - "HIV-positive TB patients on antiretroviral therapy (ART)"
	* `MWDQUNd4sZE` - "HIV-positive TB patients on co-trimoxazole preventive therapy (CPT)"
	* `TV3eW5zYLep` - "TB/HIV testing"
* Added two pivot table favourites to complete package only (these are not included in any dashboards):
	* `StXxQoaz26k` - "TBt_0.1_Notifications_all data elements_annual"
	* `dQxhOVtwwK8` - "TBt_0.2_Treatment outcomes_all data elements_annual"
* Fixed two charts where the indicator selection was empty. Both charts should have indicator `VLtzufVWnHc` "TB - New and relapse TB cases by age and sex" selected as data, and the data dimension should be set to "filter":
	*  `TfeoSE7Ha8F` - "TBc_1.2_New and relapse cases by age group and sex"
	*  `VBUUGBP8RFn` - "TBc_1.2_New and relapse cases by age group and sex (annual)"
* Fixed several indicators, including names, descriptions and formulas:

<table>
	<tr>
		<th>ID</th>
		<th>Name</th>
		<th>Modified property</th>
		<th>Old value</th>
		<th>New value</th>
	</tr>
	<tr>
		<td>lRAKLRVIMgp</td>
		<td>TB - Notified TB cases (all cases, all forms)</td>
		<td>code</td>
		<td>TB_C_NEWINC_ALL</td>
		<td>TB_C_NOTIFIED</td>
	</tr>
	<tr>
		<td>YWTs6xdTRFF</td>
		<td>TB - Notified TB cases (new and relapse, all forms)</td>
		<td>code</td>
		<td>TB_C_NEWINC_NEWREL</td>
		<td>TB_C_NEWINC</td>
	</tr>
	<tr>
		<td>fBwmklJ0VNp</td>
		<td>TB - Notified TB cases (new and relapse, all forms) aged 0-4 (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged under 0-4 (new and relapse only)</td>
		<td>Number of TB cases aged 0-4 (new and relapse only)</td>
	</tr>
	<tr>
		<td>ExXsF5qlzdc</td>
		<td>TB - Notified TB cases (new and relapse, all forms) aged 15-24 (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged 15-24 (new and relapse only)</td>
		<td>Number of TB cases aged 15-24 (new and relapse only)</td>
	</tr>
	<tr>
		<td>zyyolGvDOLQ</td>
		<td>TB - Notified TB cases (new and relapse, all forms) aged 25-34 (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged 25-34 (new and relapse only)</td>
		<td>Number of TB cases aged 25-34 (new and relapse only)</td>
	</tr>
	<tr>
		<td>v7cZx5SUBXP</td>
		<td>TB - Notified TB cases (new and relapse, all forms) aged 35-44 (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged 35-44 (new and relapse only)</td>
		<td>Number of TB cases aged 35-44 (new and relapse only)</td>
	</tr>
	<tr>
		<td>rv14EhkmZof</td>
		<td>TB - Notified TB cases (new and relapse, all forms) aged 45-54 (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged 45-54 (new and relapse only)</td>
		<td>Number of TB cases aged 45-54 (new and relapse only)</td>
	</tr>
	<tr>
		<td>zw1DhQYN9mb</td>
		<td>TB - Notified TB cases (new and relapse, all forms) aged 5-14 (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged 5-14 (new and relapse only)</td>
		<td>Number of TB cases aged 5-14 (new and relapse only)</td>
	</tr>
	<tr>
		<td>TV1Qm6X0ILb</td>
		<td>TB - Notified TB cases (new and relapse, all forms) aged 55-64 (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged 55-64 (new and relapse only)</td>
		<td>Number of TB cases aged 55-64 (new and relapse only)</td>
	</tr>
	<tr>
		<td>vwRyMhcuZDh</td>
		<td>TB - Notified TB cases (new and relapse, all forms) aged 65+ (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged 65+ (new and relapse only)</td>
		<td>Number of TB cases aged 65+ (new and relapse only)</td>
	</tr>
	<tr>
		<td>aPT4OksC5z7</td>
		<td>TB - Notified TB cases (new and relapse, all forms) children aged 0-14 (%)</td>
		<td>numeratorDescription</td>
		<td>Number of children aged under 15</td>
		<td>Number of TB cases aged 0-15 (new and relapse only)</td>
	</tr>
	<tr>
		<td>JCs9GgdcC7d</td>
		<td>TB - Notified TB cases (new and relapse, pulmonary clinically diagnosed)</td>
		<td>code</td>
		<td>TB_C_NEWINC_CLINCONF</td>
		<td>TB_C_NEWINC_CLINDX</td>
	</tr>
	<tr>
		<td>JCs9GgdcC7d</td>
		<td>TB - Notified TB cases (new and relapse, pulmonary clinically diagnosed)</td>
		<td>numeratorDescription</td>
		<td>Pulm bact confirmed new and relapse and history unknown</td>
		<td>Pulmonary clinically diagnosed new and relapse and history unknown</td>
	</tr>
	<tr>
		<td>JCs9GgdcC7d</td>
		<td>TB - Notified TB cases (new and relapse, pulmonary clinically diagnosed)</td>
		<td>numerator</td>
		<td>#{voLCYElGAjX} + #{qlkxnlC6dzU} + #{NYxehRdsQx3} + #{EGlb6CP7czB}"</td>
		<td>#{voLCYElGAjX} + #{qlkxnlC6dzU} + #{NYxehRdsQx3} + #{EGlb6CP7czB}+ #{v2qRhkUmjlV} + #{XLV3S8QL8jV} + #{PRB6dolaxC4}</td>
	</tr>
	<tr>
		<td>VcwgKNqXO9n</td>
		<td>TB - Ratio of TB cases aged 0-4:5-14 (new and relapse, all forms)</td>
		<td>numeratorDescription</td>
		<td>Cases aged 0-4</td>
		<td>Number of TB cases aged 0-4 (new and relapse, all forms)</td>
	</tr>
	<tr>
		<td>VcwgKNqXO9n</td>
		<td>TB - Ratio of TB cases aged 0-4:5-14 (new and relapse, all forms)</td>
		<td>denominatorDescription</td>
		<td>Cases in children aged 5-14</td>
		<td>Number of TB cases aged 5-14 (new and relapse, all forms)</td>
	</tr>
	<tr>
		<td>cX7gRvEV6kK</td>
		<td>TB - TB cases tested for susceptibility to rifampicin (%)</td>
		<td>description</td>
		<td>All TB cases tested for susceptibility to rifampicin - RR-TB(%)</td>
		<td>All TB cases tested for susceptibility to rifampicin (RR-TB) as a percentage of all TB cases notified</td>
	</tr>
	<tr>
		<td>Fyx8nuRcxja</td>
		<td>TB - TB cases tested for susceptibility to rifampicin (new) (%)</td>
		<td>description</td>
		<td>New TB cases tested for susceptibility to rifampicin - RR-TB(%)</td>
		<td>New TB cases tested for susceptibility to rifampicin (RR-TB) as a percentage of all new TB cases notified</td>
	</tr>
	<tr>
		<td>Fyx8nuRcxja</td>
		<td>TB - TB cases tested for susceptibility to rifampicin (new) (%)</td>
		<td>denominatorDescription</td>
		<td>Total notified</td>
		<td>All new TB cases notified (excluding the cases with unknown treatment history)</td>
	</tr>
	<tr>
		<td>Fyx8nuRcxja</td>
		<td>TB - TB cases tested for susceptibility to rifampicin (new) (%)</td>
		<td>denominator</td>
		<td>#{wadYJEcT9yh} + #{voLCYElGAjX} + #{v2qRhkUmjlV} + #{ZiF0ngznP1Z} + #{XLV3S8QL8jV} + #{hKTgk1mG2qn} + #{PdhQ1JCS2ij} + #{M6JHtLJJ34t} + #{KZ7rMA7BqcQ} + #{PRB6dolaxC4} + #{Orjo9ewlU9Z} + #{qlkxnlC6dzU} + #{l4TyT04yP8f} + #{NYxehRdsQx3} +#{QNFhsj0fOxK} + #{Nv1RGi4eI7F} + #{NJaeD9Xia7x} + #{KhCB35MHs9A} + #{lgKh8oeoKVj} + #{EGlb6CP7czB} + #{Q5KSbP9ZzHQ}</td>
		<td>#{wadYJEcT9yh} + #{voLCYElGAjX} + #{v2qRhkUmjlV} + #{ZiF0ngznP1Z} + #{XLV3S8QL8jV} + #{Orjo9ewlU9Z} + #{qlkxnlC6dzU}</td>
	</tr>
	<tr>
		<td>whkj4kr4ghD</td>
		<td>TB - TB cases tested for susceptibility to rifampicin (previously treated) (%)</td>
		<td>description</td>
		<td>Previously treated TB cases (including relapses) tested for susceptibility to rifampicin - RR-TB (%)</td>
		<td>Previously treated TB cases (including relapses) tested for susceptibility to rifampicin (RR-TB) as a percentage of all previously treated (including relapses) TB cases notified</td>
	</tr>
	<tr>
		<td>whkj4kr4ghD</td>
		<td>TB - TB cases tested for susceptibility to rifampicin (previously treated) (%)</td>
		<td>denominatorDescription</td>
		<td>Total notified</td>
		<td>All previously treated (including relapses) TB cases notified</td>
	</tr>
	<tr>
		<td>whkj4kr4ghD</td>
		<td>TB - TB cases tested for susceptibility to rifampicin (previously treated) (%)</td>
		<td>denominator</td>
		<td>#{wadYJEcT9yh} + #{voLCYElGAjX} + #{v2qRhkUmjlV} + #{ZiF0ngznP1Z} + #{XLV3S8QL8jV} + #{hKTgk1mG2qn} + #{PdhQ1JCS2ij} + #{M6JHtLJJ34t} + #{KZ7rMA7BqcQ} + #{PRB6dolaxC4} + #{Orjo9ewlU9Z} + #{qlkxnlC6dzU} + #{l4TyT04yP8f} + #{NYxehRdsQx3} +#{QNFhsj0fOxK} + #{Nv1RGi4eI7F} + #{NJaeD9Xia7x} + #{KhCB35MHs9A} + #{lgKh8oeoKVj} + #{EGlb6CP7czB} + #{Q5KSbP9ZzHQ}</td>
		<td>#{hKTgk1mG2qn} + #{PdhQ1JCS2ij} + #{M6JHtLJJ34t} + #{KZ7rMA7BqcQ} + #{PRB6dolaxC4} + #{Orjo9ewlU9Z} + #{qlkxnlC6dzU} + #{l4TyT04yP8f} + #{NYxehRdsQx3} +#{QNFhsj0fOxK} + #{Nv1RGi4eI7F} + #{NJaeD9Xia7x} + #{KhCB35MHs9A}</td>
	</tr>
	<tr>
		<td>WWephINt8ga</td>
		<td>TB - TB notification rate (all cases, all forms) per 100 000 population</td>
		<td>code</td>
		<td>TB_C_ALLINC_100K</td>
		<td>TB_C_NOTIFIED_100K</td>
	</tr>
	<tr>
		<td>o7QoPpjWR9h</td>
		<td>TB - TB notification rate (new and relapse, pulmonary clinically diagnosed) per 100 000 population</td>
		<td>code</td>
		<td>TB_C_NEWINC_CLINDIAG_100K</td>
		<td>TB_C_NEWINC_CLINDX_100K</td>
	</tr>
	<tr>
		<td>o7QoPpjWR9h</td>
		<td>TB - TB notification rate (new and relapse, pulmonary clinically diagnosed) per 100 000 population</td>
		<td>numerator</td>
		<td>#{voLCYElGAjX}+ #{v2qRhkUmjlV}+#{XLV3S8QL8jV}+#{PRB6dolaxC4}+#{qlkxnlC6dzU}+#{NYxehRdsQx3}+#{NJaeD9Xia7x}+ #{EGlb6CP7czB}</td>
		<td>#{voLCYElGAjX} + #{v2qRhkUmjlV} + #{XLV3S8QL8jV} + #{PRB6dolaxC4} + #{qlkxnlC6dzU} + #{NYxehRdsQx3} + #{EGlb6CP7czB}</td>
	</tr>
	<tr>
		<td>SPJLukKxHaj</td>
		<td>TB - TB treatment success rate (all DS and DR-TB) (%)</td>
		<td>description</td>
		<td>Number of all DS+DR TB cases who were successfully treated (cured or who completed their treatment) as a percentage of the total cohort of all DS+DR TB cases registered, excluding cases moved to second-line treatment</td>
		<td>Number of all DS+DR TB cases who were successfully treated (cured or who completed their treatment) as a percentage of the total cohort of all DS+DR TB cases registered.</td>
	</tr>
</table>

* Added indicators, charts and maps (specified below), which should be considered "additional", and provide alternative outputs that can be useful for analysing historical data in some circumstances. In particular, they provide visualisations for alternative age disaggregations used by some countries previously:
<table>
	<tr>
		<th>Type</th>
		<th>ID</th>
		<th>Name</th>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>PgU1N0PfAwN</td>
		<td>TB - Notified TB cases (new, pulmonary smear positive) by age group and sex</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>SrgAuZUkqHh</td>
		<td>TB - TB cases tested for HIV or with known HIV status - all cases (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>HBkfpoEMWna</td>
		<td>TB - Notified TB cases (new, all forms) aged 55-64 (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>eIG3AwbOY4k</td>
		<td>TB - Notified TB cases (new, all forms) aged 65+ (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>trwSfpxsWcb</td>
		<td>TB - Notified TB cases (new, all forms) aged 45-54 (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>GjDECoLvM1z</td>
		<td>TB - Notified TB cases (new, all forms) aged 5-14 (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>cT1tyz6k18X</td>
		<td>TB - Notified TB cases (new, all forms) aged 35-44 (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>B1HKzq73wJr</td>
		<td>TB - Notified TB cases (new, all forms) aged 15-24 (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>KlETO0IOKtI</td>
		<td>TB - Notified TB cases (new, all forms) aged 25-34 (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>aPfDXoI0tPS</td>
		<td>TB - Notified TB cases (new, all forms) aged 0-14 (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>jU1JpPt2T62</td>
		<td>TB - Notified TB cases (new, all forms) aged 0-4 (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>aArkaKMHNhw</td>
		<td>TB - Not evaluated (new and relapse pulmonary bacteriologically confirmed DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>N7OZj7DONas</td>
		<td>TB - Not evaluated (previously treated DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>xlmDFjsyuiS</td>
		<td>TB - Not evaluated (all DR-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>HSLNfDLCbUc</td>
		<td>TB - Not evaluated (all DS-TB/HIV cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>c5yG2hQbSWF</td>
		<td>TB - Lost to follow-up (previously treated DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>w3CiHTdwV4j</td>
		<td>TB - Lost to follow-up (all DS-TB/HIV cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>NNwvy3Ym6vj</td>
		<td>TB - Lost to follow-up (new and relapse pulmonary bacteriologically confirmed DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>nhoEcbYl2hU</td>
		<td>TB - Failed (previously treated DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>Tm4N8CLJM9I</td>
		<td>TB - Lost to follow-up (all DR-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>m0VAZ280hFd</td>
		<td>TB - Failed (all DS-TB/HIV cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>XjyUl0Jmjbj</td>
		<td>TB - Failed (new and relapse pulmonary bacteriologically confirmed DS-TB cases)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>wTmoLwBYFa8</td>
		<td>TB - Died (previously treated DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>P6wlyWUyJHp</td>
		<td>TB - Failed (all DR-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>gHZcDFFvq5x</td>
		<td>TB - Died (new and relapse pulmonary bacteriologically confirmed DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>RlFZHghqtq7</td>
		<td>TB - Died (all DS-TB/HIV cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>c6ju86FLKzU</td>
		<td>TB - Died (all DR-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>WCE27g52nBt</td>
		<td>TB - Cured (new and relapse pulmonary bacteriologically confirmed DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>OuSWXCijKks</td>
		<td>TB - Cured (previously treated DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>VTNrh2DfO91</td>
		<td>TB - Cured (all DS-TB/HIV cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>JfrM1j1pYhc</td>
		<td>TB - Cured (all DR-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>HBB4o9xQScX</td>
		<td>TB - Completed (previously treated DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>AAiHWXynwMP</td>
		<td>TB - Completed (new and relapse pulmonary bacteriologically confirmed DS-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>RgcWLiawMTQ</td>
		<td>TB - Completed (all DS-TB/HIV cases) (%)</td>
	</tr>
	<tr>
		<td>Indicator</td>
		<td>L6TXyCTI2mW</td>
		<td>TB - Completed (all DR-TB cases) (%)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>b8BvZ2yyAGI</td>
		<td>TBc_1.2a_New smear positive by age group and sex (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>NpBI7jrzA0z</td>
		<td>TBc_1.3a_New cases (all forms) by age group (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>zvXhppFsdjd</td>
		<td>TBc_1.3b_New smear positive cases by age group (0-14 group) (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>cT3HLHVOOwF</td>
		<td>TBc_4.3a_Treatment outcomes for DS-TB/HIV (%)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>q9Tag5rbuDJ</td>
		<td>TBc_4.3a_Treatment outcomes for DS-TB/HIV (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>A3sd6M0Ar3A</td>
		<td>TBc_4.3b_Treatment outcomes for previously treated DS-TB (%)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>UHn8QRtiKGH</td>
		<td>TBc_4.3b_Treatment outcomes for previously treated DS-TB (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>Fw0CsA5Dpvf</td>
		<td>TBc_4.3c_Treatment outcomes for DR-TB (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>qjAxCdXK4it</td>
		<td>TBc_4.3d_Treatment outcomes for bacteriologically confirmed DS-TB (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>ORUu9PBi84b</td>
		<td>TBc_4.3e_Treatment outcomes for smear positive DS-TB (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>ztsp2Ew6kdN</td>
		<td>TBc_6.2a_TB/HIV cascade of care (all cases)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>gOYlLJb51tn</td>
		<td>TBc_6.2a_TB/HIV cascade of care (all cases) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>BSKSZRKbSUU</td>
		<td>TBc_6.2b_TB/HIV cascade of care (%)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>dXIKcGcRfC4</td>
		<td>TBc_6.2b_TB/HIV cascade of care (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>cS2kUPAkWri</td>
		<td>TBc_6.2c_TB/HIV cascade of care (all cases) (%)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>qmmhMtrCtby</td>
		<td>TBc_6.2c_TB/HIV cascade of care (all cases) (%) (annual)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>obyjcDqxXls</td>
		<td>TBc_6.3a_TB/HIV – all TB cases (%)</td>
	</tr>
	<tr>
		<td>Chart</td>
		<td>xpiCsSSLVXp</td>
		<td>TBc_6.3a_TB/HIV – all TB cases (%) (annual)</td>
	</tr>
	<tr>
		<td>Map</td>
		<td>R2kLLio5dEv</td>
		<td>TBm_6.1a_All TB cases with known HIV status in 2017 (%) (annual)</td>
	</tr>
	<tr>
		<td>Map</td>
		<td>ICV9ugEX8hT</td>
		<td>TBm_6.1a_All TB cases with known HIV status in 2017Q4 (%)</td>
	</tr>
</table>
