# PHS_penguin_team_project
 
## Project description

About the project, its purpose


From the data available, we were able to explore several key performance indicators (KPIs) of acute care provision, including client intake (A&E attendances and hospital admissions), measures of service workload within the service (wait times in A&E and for hospital treatment, length of stay, bed occupancy), and an outflow metric that affects service capacity and resources (delayed discharge).

![Key indicators of acute care provision included in the available datasets](images/covid_kpis_all.drawio.png)

To understand the impact of COVID-19 pandemic, we focused on three key indicators that cover the flow of clients into, within and out of hospital care: hospital admissions, bed occupancy, and delayed discharge.

To investigate seasonality, we focussed on A&E attendances, because we found a seasonal pattern here (also in A&E wait times) whereas we did not find any seasonality in other indicators.


## Contributors

About us

## About the data
 
This project uses data from Public Health Scotland and NHS Scotland, which contains public sector information licensed under the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

The Shiny dashboard presents data from the following specific datasets: 

* Monthly A&E activity and waiting times: https://www.opendata.nhs.scot/dataset/monthly-accident-and-emergency-activity-and-waiting-times  
* COVID-19 Wider Impacts - Hospital Admissions: https://www.opendata.nhs.scot/dataset/covid-19-wider-impacts-hospital-admissions 
* [for occupancy] Beds Information in Scotland: https://www.opendata.nhs.scot/dataset/hospital-beds-information 
* Delayed Discharges in NHS Scotland: https://www.opendata.nhs.scot/dataset/delayed-discharges-in-nhsscotland
* NHS Scotland Hospital Locations:
https://www.opendata.nhs.scot/dataset/hospital-codes/resource/c698f450-eeed-41a0-88f7-c1e40a568acc

Exploration notebooks also include work using these additional datasets:

* Treatment wait times: https://www.opendata.nhs.scot/dataset/stage-of-treatment-waiting-times
* Inpatient and day cases activity (including length of stay):
  * Activity by Board of Treatment and Specialty: https://www.opendata.nhs.scot/dataset/inpatient-and-daycase-activity/resource/c3b4be64-5fb4-4a2f-af41-b0012f0a276a
  * Activity by Board of Treatment, Age and Sex: https://www.opendata.nhs.scot/dataset/inpatient-and-daycase-activity/resource/00c00ecc-b533-426e-a433-42d79bdea5d4
  * Activity by Board of Treatment and Deprivation: https://www.opendata.nhs.scot/dataset/inpatient-and-daycase-activity/resource/4fc640aa-bdd4-4fbe-805b-1da1c8ed6383

## Running the app locally

<show snapshot of what it looks like?>

### Requirements

List packages used and versions

Instructions for how to run app locally:

1. **Download raw data:** download .csv data from websites above 
2. **Prepare cleaned data:** run all 5 cleaning scripts (in any order) - these will write new csvs into data/cleaned_data folder within your project directory, which are required for:
3. **Run the R Shiny dashboard locally:** run one of global, ui, server scripts - the shiny dashboard should load in your web browser

Note we downloaded the raw data files on ~July 7-14 2023. Any updates to the open data webpages since this date may affect whether the cleaning scripts run as expected. (We have not included data validation steps... yet.)


## Process / other contents

What's in the repo, what does it do (in brief)

