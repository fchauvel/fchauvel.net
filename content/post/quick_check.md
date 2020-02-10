+++
banner = "images/code.jpg"
categories = ["software"]
date = "2020-02-05T15:57:00+02:00"
description = "Quick-Check, a JS library to validate and convert JSON object trees"
images = []
menu = ""
tags = ["NodeJS", "Code", "Open-Source"]
title = "Introducing Quick-check"
+++

I recently released
[quick-check](https://fchauvel.github.io/quick-check/index.html), a
JS library to easily declare data schema and validate and convert data
accordinly.

## Why Yet Another Library?

I did not find anything that fits my need. I ended up writing some
boiler-plate code, code to convert object trees (i.e., maps and lists)
into home-grown classes, first while working on the [CAMP
project](https://github.com/STAMP-project/camp) (Python), and then on
my [RPP project](https://fchauvel.github.io/rpp/index.html).

I did find though libraries to convert JSON files into home-grown
classes, using annotations for instance, but in my case, I needed to
accept both objects trees from multiple syntax files, say TOML and
YAML for instance, which I parsed using different libraries.

## Declaring Schemas

Using quick-check, I can declare data schemas directly in the code, in
a way that serves as documentation, and that cannot go out of date. For
instance, in the following, I declare a schema to represent a tree of
teams (where teams are made of either persons or other teams).

```typescript
export const teamSchema = new Grammar();
teamSchema.define("team")
    .as(anObject()
        .with(aProperty("name").ofType("string"))
        .with(aProperty("members")
              .ofType(anArrayOf(eitherOf("person", "team")))));

teamSchema.define("person")
    .as(anObject()
        .with(aProperty("firstname").ofType("string"))
        .with(aProperty("lastname").ofType("string"))
```

## Parsing Data

Given this schema&mdash;which I can directly refer to as
documentation&mdash;I can now parse my data file using:

```typescript {hl_lines=[5]}
const fileContent = fs.readFileSync('./data.yaml', 'utf8');
const data = yaml.safeLoad(fileContents);

try {
    const team = schema.read(data).as("team");

} catch (errors) {
    console.log(errors);

}
```

## Converting Data

By constrast, my custom classes looks like the following UML class
diagram:

![UML class
diagram](https://raw.githubusercontent.com/fchauvel/quick-check/master/docs/_images/team_class_diagram.png)

To ease the convertion, I can attach a convertion function to each
type my schema has, as follows:

```typescript
teamSchema.on("team")
    .apply( (data) => {
        return new Team(data.name, data.members);
    }
);
```

This allows me to quickly validate the data I read from files and to
directly instantiates my custom classes.
