#!/usr/bin/env bash

GITROOT=$(git rev-parse --show-toplevel)
AUTHOR=ruittenb
PROJECT=Spaceman
PBXPROJ=$GITROOT/$PROJECT.xcodeproj/project.pbxproj
BUILDDIR=build
URL=https://api.github.com/repos/$AUTHOR/$PROJECT/releases/latest

############################################################################
# functions

print_xml() {
    cat <<-EOF
<?xml version="1.0" standalone="yes"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
    <channel>
        <title>${PROJECT}</title>
        <item>
            <title>${title}</title>
            <description>
                <![CDATA[
                    <ul>
                    ${description}
                    </ul>
                ]]>
            </description>
            <pubDate>${pubDate}</pubDate>
            <sparkle:minimumSystemVersion>${minimumSystemVersion}</sparkle:minimumSystemVersion>
            <enclosure
                url="https://github.com/${AUTHOR}/${PROJECT}/releases/download/v${version}/${imageFile}"
                sparkle:version="${numericVersion}"
                sparkle:shortVersionString="${friendlyVersion}"
                type="application/octet-stream"
                ${signatureAndLength}
            />
        </item>
    </channel>
</rss>
EOF
}

get_github_release() {
    release_data=$(wget -qO- "$URL")
}

gather_data() {
    local sparkle_dir=$(
        ls -d1 ~/Library/Developer/Xcode/DerivedData/Spaceman-*/SourcePackages/artifacts/sparkle/Sparkle/bin | head -1
    )

    local body=$(echo "$release_data" | jq -r .body)
    local publishedAt=$(echo "$release_data" | jq -r .published_at)
    local vversion=$(echo "$release_data" | jq -r .tag_name)

    title=$(echo "$release_data" | jq -r .name)
    imageFile=$(echo "$release_data" | jq -r .assets[].name)

    description=$(printf -- "$body" | awk '{ gsub("\r", ""); print "<li>" $0 "</li>" }')
    pubDate=$(gdate -R -d "$publishedAt")
    version=${vversion#v}
    friendlyVersion=${version}
    numericVersion=${version%-R}
    minimumSystemVersion=$(awk -F'[=; ]{1,}' '/MACOSX_DEPLOYMENT_TARGET/ { print $2; exit }' "$PBXPROJ")

    signatureAndLength=$("$sparkle_dir"/sign_update "$BUILDDIR/$imageFile" | awk '{ print $2 "\n" $1 }')
}

main() {
    get_github_release
    gather_data
    print_xml
}

############################################################################
# main

main "$@"

