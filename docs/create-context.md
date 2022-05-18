# Create Context

Create sets up an object using the build functionality, and then attempts to save it to the data source.

Create does the following:

- Creates a new model
- Assigns attributes
- Saves Object

##### Example

```ruby
class PeopleContext
  include SnFoil::CRUD::CreateContext

  policy PersonPolicy
  model Person
end
```
#### Required Class Definitions

- Policy
- Model

### Primary Action
Saves the model.
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
        Creates a new model, Assigns attributes
      </td>
    </tr>
    <tr>
      <td>setup_change</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>setup_create</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>before_change</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>before_create</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change_success</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>after_create_success</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change_failure</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>after_create_failure</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change</td>
      <td>Shared by Create, Update, and Destroy actions</td>
      <td></td>
    </tr>
    <tr>
      <td>after_create</td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>

### ORM Adapter Requirements

The following methods must be defined on the ORM adapter to use the create context

- `new`
- `attributes=`
- `save`
