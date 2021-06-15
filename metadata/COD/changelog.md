# WHO Cause of Death - Change log

## 1.2.0

### General changes

- All SQL views have been reconfigured for the newer versions of DHIS2.

| Name | id | Program |
|:-|-|-|
| CoD: Anacod export 2017 | nOrVs1Gi9Nt | Event |
| CoD: Anacod export 2018 | iy8xEmIhMph | Event |
| CoD: Anacod export 2019 | ojaXg9yV9is | Event |
| CoD: Anacod export 2020 | atLa12jpN4y | Event |
| CoD: Anacod export 2017 | fn3zQtRrETh | Tracker |
| CoD: Anacod export 2018 | KdIAkgUzCv7 | Tracker |
| CoD: Anacod export 2019 | xzxuZVKZw3A | Tracker |
| CoD: Anacod export 2020 | hMLDxoR33ej | Tracker |
| CoD: Dictionary entries mixing main- and sub-categories | Siuqk0lMzC7 | Event and Tracker |
| CoD: Dictionary entries with invalid ICD-SMoL reference | nWsSOLLJPjG | Event and Tracker |
| CoD: Dictionary entries with invalid code format | dS3uFpYtlss | Event and Tracker |
| CoD: Dictionary terms with ICD (for IRIS) | DNveLCRg2zU | Event and Tracker |
| CoD: Next dictionary index number | ekC6LY25qMk | Event and Tracker |
| CoD: Terms not found in dictionary | ZVl5kudO8Vt | Event |
| CoD: Terms not found in dictionary | hhrfqhx47bt | Tracker |

- Standard reports (Validation) for Event and Tracker programs have been reconfigured. It is possible to open applicable enrollments/events directly from the standard report form by using the right-click.

- Duplicate options from **ICD-SMoL - local dictionary** option set were removed. Additional COVID-19 related options were added. See metadata reference file for details. All option names were changed to all-caps format.

- ID replacement

| Object | Property | Old value | New value | Program |
|-|-|-|-|-|
| option | id | CvivP1rh4ii | x9yVKkv9koc | Event and Tracker |
| option | id | PLlPgcfbL1D | R98tI2c6rF5 | Event and Tracker |
| option | id | TKD1XJ4ZhMO | pqxvAQU1z9W | Event and Tracker |
| optionSet| id | bLA3AqDKdwx | L6eMZDJkCwX | Event and Tracker |
| indicatorType | id | e1jRVY5Mcq0 | hmSnCXmLYwt | Event and Tracker |
| trackedEntityAttribute | id | flGbXLXCrEo | HAZ7VQ730yn | Tracker |
| dataElement | id | YUcJrLWmGyv | G5ljtyKdtYU | Event and Tracker |

- French Dictionary for the localised French package

The French localised version of the Cause of Death package uses a different **ICD-SMoL - local dictionary** than the generic package. It consists of different options and uses `INT_FRxxxxx` as a prefix in the segment 3 of the option code. See metadata reference file for the French localised package for more details.

## 1.1.0

### Tracker

- Included SQL views in metadata file
- Updated the following options:

| id | Property | Old value | New value |
|-|-|-|-|
| y400ZT7P7Tk | code | 5-2\|A019\|INT00638 | 5-2\|A010\|INT00638 |
| nW8UW4mIHoj | code | 5-80\|O16/O15\|INT05700 | 5-80\|O16\|INT05700 |
| eGSBH8BXVxt | code | 5-106\|T309\|INT05605 | 5-106\|T300\|INT05605 |
| Wvw6LctDL3R | code | 5-106\|T309\|INT00043 | 5-106\|T300\|INT00043 |
| V8CuD9AucgW | code | 5-85\|O999\|INT02339 | 5-85\|O998\|INT02339 |

- Deleted the following options: `oBOM5bEVVLk, LW7CuavQo3n, leyPoGqs597, k7XHmj3a4nT, trEzz9R11r5, OrqWo8PX6f2, HopjEbx2cdt, C0RFtymQ1zT, VOW0QufZ5NM, w4TLLFtwyMy`

### Event

- Included SQL views in metadata file
- Updated the following options:

| id | Property | Old value | New value |
|-|-|-|-|
| y400ZT7P7Tk | code | 5-2\|A019\|INT00638 | 5-2\|A010\|INT00638 |
| nW8UW4mIHoj | code | 5-80\|O16/O15\|INT05700 | 5-80\|O16\|INT05700 |
| eGSBH8BXVxt | code | 5-106\|T309\|INT05605 | 5-106\|T300\|INT05605 |
| Wvw6LctDL3R | code | 5-106\|T309\|INT00043 | 5-106\|T300\|INT00043 |
| V8CuD9AucgW | code | 5-85\|O999\|INT02339 | 5-85\|O998\|INT02339 |

- Deleted the following options: `oBOM5bEVVLk, LW7CuavQo3n, leyPoGqs597, k7XHmj3a4nT, trEzz9R11r5, OrqWo8PX6f2, HopjEbx2cdt, C0RFtymQ1zT, VOW0QufZ5NM, w4TLLFtwyMy`
