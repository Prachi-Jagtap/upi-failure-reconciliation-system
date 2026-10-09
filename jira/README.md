# Jira Backlog

`backlog.csv` can be imported via Jira: **Project settings > Import issues from CSV** (map columns: Issue Type, Summary, Epic Link, Priority, Story Points, Sprint, Labels, Description).

## Release Plan (2-week sprints, velocity ~20 pts)
| Sprint | Goal | Stories | Points |
|---|---|---|---|
| 1 | Ingestion and validation | US-01, US-02, US-03 | 13 (+ tech tasks) |
| 2 | Matching and reversal tracking | US-04, US-06, US-07, US-08 | 23 |
| 3 | Exception handling | US-05, US-09, US-10, US-11 | 21 |
| 4 | Notifications, disputes, MIS, API | US-12, US-13, US-14, US-15 | 21 |
| 5 | Hardening, UAT, parallel run | US-16 + defects | 5 + UAT |

## Definition of Ready
Story has INVEST format, acceptance criteria, linked FR, dependencies identified, estimate agreed.

## Definition of Done
Code reviewed, unit and SIT tests passed, acceptance criteria demonstrated, UAT cases updated, documentation and RTM updated.
