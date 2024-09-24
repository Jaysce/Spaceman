
## Feature: Add Apple Script Refresh Command

[mike-jl](https://github.com/mike-jl) [commented on May 30](https://github.com/Jaysce/Spaceman/pull/34):

It is possible to refresh Spaceman using the following Apple Script command:

```applescript
tell application "Spaceman" to refresh
```

When using yabai, you can make sure that the icons stay up to date with the following code added to the end of yabairc:

```sh
signals=(
   "space_changed"
   "display_added"
   "display_removed"
   "display_moved"
   "display_changed"
   "mission_control_enter"
   "mission_control_exit"
   "space_created"
   "space_destroyed"
)
for signal in "${signals[@]}"
do
   yabai --message signal \
         --add \
            event=$signal \
            action="osascript -e 'tell application \"Spaceman\" to refresh'"
done
```
