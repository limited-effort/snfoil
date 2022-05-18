# Build Context

Build is meant to setup an object, but not to actually save it (that is handled by Create).

Build does the following:

- Creates a new model object
- Assigns Attributes

Since build's usage is pretty straight forward it only adds a single interval for you to hook into.

##### Example

```ruby
class PeopleContext
  include SnFoil::CRUD::BuildContext

  model Person
end
```
### Required Class Definitions
- Model
  
### Primary Action
Does nothing
### Intervals (in order)

<table>
  <thead>
    <th>name</th>
    <th>description</th>
    <th>pre-defined functions</th>
  </thead>

  <tbody>
    <tr>
      <td>setup</td>
      <td>Shared by all CRUD actions</td>
      <td></td>
    </tr>
    <tr>
      <td>setup_build</td>
      <td>Shared by Build and Create actions</td>
      <td>
        Creates a new model object, Assigns Attributes
      </td>
    </tr>
  </tbody>
</table>

### ORM Adapter Requirements

The following methods must be defined on the ORM adapter to use the build context

- `new`
- `attributes=`
